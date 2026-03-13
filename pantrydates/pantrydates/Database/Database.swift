// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct AppDatabase {
  let writer: DatabaseWriter

  init(_ writer: DatabaseWriter) throws {
    self.writer = writer
    try migrator.migrate(writer)
  }

  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif

    migrator.registerMigration("v1") { db in
      try db.create(table: "pantryItem") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("name", .text).notNull()
        t.column("expirationDate", .datetime).notNull()
      }
    }

    migrator.registerMigration("v2") { db in
      try db.alter(table: "pantryItem") { t in
        t.add(column: "flagged", .boolean).notNull().defaults(to: false)
      }
    }

    migrator.registerMigration("v3") { db in
      try db.alter(table: "pantryItem") { t in
        t.add(column: "notificationDate", .datetime)
      }
    }

    migrator.registerMigration("v4") { db in
      try db.alter(table: "pantryItem") { t in
        t.add(column: "notificationSent", .boolean).notNull().defaults(to: false)
      }
    }

    migrator.registerMigration("v5") { db in
      try db.alter(table: "pantryItem") { t in
        t.add(column: "notes", .text).notNull().defaults(to: "")
      }
    }

    migrator.registerMigration("v6") { db in
      try db.rename(table: "pantryItem", to: "foodItem")
    }

    migrator.registerMigration("v7") { db in
      try db.alter(table: "foodItem") { t in
        t.add(column: "refrigerated", .boolean).notNull().defaults(to: false)
      }
    }

    migrator.registerMigration("v8") { db in
      try db.alter(table: "foodItem") { t in
        t.add(column: "symbolName", .text).notNull().defaults(to: "fork.knife")
      }
    }

    // Migrate from SF Symbols to Lucide icons
    migrator.registerMigration("v9") { db in
      try db.execute(sql: "UPDATE foodItem SET symbolName = 'utensils'")
    }

    // Remove notification columns
    migrator.registerMigration("v10") { db in
      try db.alter(table: "foodItem") { t in
        t.drop(column: "notificationDate")
        t.drop(column: "notificationSent")
      }
    }

    migrator.registerMigration("v11") { db in
      try db.create(table: "finishedItem") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("name", .text).notNull()
        t.column("finishedDate", .datetime).notNull()
      }
    }

    migrator.registerMigration("v12") { db in
      try db.alter(table: "finishedItem") { t in
        t.add(column: "notes", .text).notNull().defaults(to: "")
        t.add(column: "flagged", .boolean).notNull().defaults(to: false)
        t.add(column: "refrigerated", .boolean)
          .notNull().defaults(to: false)
        t.add(column: "symbolName", .text)
          .notNull().defaults(to: "utensils")
      }
      try db.execute(
        sql: """
          UPDATE finishedItem
          SET refrigerated = 1, flagged = 1
          """
      )
    }

    // Move expirationDate to separate table
    migrator.registerMigration("v13") { db in
      try db.create(table: "expirationDate") { t in
        t.autoIncrementedPrimaryKey("id")
        t.belongsTo("foodItem", onDelete: .cascade).notNull()
        t.column("date", .datetime).notNull()
      }

      try db.execute(
        sql: """
          INSERT INTO expirationDate (foodItemId, date)
          SELECT id, expirationDate FROM foodItem
          """
      )

      try db.alter(table: "foodItem") { t in
        t.drop(column: "expirationDate")
      }
    }

    return migrator
  }
}

extension AppDatabase {
  static func makeDefault() throws -> AppDatabase {
    let fileManager = FileManager.default
    let appSupportURL = try fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

    let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
    let writer = try DatabaseQueue(path: databaseURL.path)
    return try AppDatabase(writer)
  }

  static func makeEmpty() throws -> AppDatabase {
    let writer = try DatabaseQueue()
    return try AppDatabase(writer)
  }
}

// MARK: - Food Items

extension AppDatabase {
  func observeAllItemInfos() -> AsyncValueObservation<[FoodItemInfo]> {
    let observation = ValueObservation.tracking { db in
      let request = FoodItem.including(all: FoodItem.expirationDates)
      var infos = try FoodItemInfo.fetchAll(db, request)
      infos.sort { a, b in
        let aDate = a.mostImminentDate ?? .distantFuture
        let bDate = b.mostImminentDate ?? .distantFuture
        return aDate < bDate
      }
      return infos
    }
    return observation.values(in: writer)
  }

  @discardableResult
  func saveItem(_ item: inout FoodItem) throws -> Int64 {
    try writer.write { db in
      try item.save(db)
    }
    guard let id = item.id else {
      fatalError("ID should always be set after successful save")
    }
    return id
  }

  @discardableResult
  func saveNewItem(
    _ item: inout FoodItem,
    expirationDates: [Date]
  ) throws -> Int64 {
    try writer.write { db in
      try item.save(db)
      guard let id = item.id else {
        fatalError(
          "ID should always be set after successful save"
        )
      }
      for date in expirationDates {
        var expDate = ExpirationDate(
          foodItemId: id,
          date: date
        )
        try expDate.insert(db)
      }
      return id
    }
  }

  func deleteItem(_ item: FoodItem) throws {
    try writer.write { db in
      _ = try item.delete(db)
    }
  }

  func deleteItem(id: Int64) throws {
    try writer.write { db in
      _ = try FoodItem.deleteOne(db, key: id)
    }
  }

  func toggleFlagged(id: Int64) throws {
    try writer.write { db in
      if var item = try FoodItem.fetchOne(db, key: id) {
        item.flagged.toggle()
        try item.update(db)
      }
    }
  }

  func updateSymbol(id: Int64, symbolName: String) throws {
    try writer.write { db in
      if var item = try FoodItem.fetchOne(db, key: id) {
        item.symbolName = symbolName
        try item.update(db)
      }
    }
  }

  func finishItemDate(_ info: FoodItemInfo) throws {
    try writer.write { db in
      var finished = FinishedItem(
        name: info.foodItem.name,
        notes: info.foodItem.notes,
        finishedDate: Date(),
        flagged: info.foodItem.flagged,
        refrigerated: info.foodItem.refrigerated,
        symbolName: info.foodItem.symbolName
      )
      try finished.insert(db)

      let sorted = info.sortedDates
      if sorted.count <= 1 {
        _ = try info.foodItem.delete(db)
      } else if let mostImminent = sorted.first {
        _ = try mostImminent.delete(db)
      }
    }
  }
}

// MARK: - Expiration Dates

extension AppDatabase {
  @discardableResult
  func addExpirationDate(foodItemId: Int64, date: Date) throws -> ExpirationDate {
    try writer.write { db in
      var expDate = ExpirationDate(foodItemId: foodItemId, date: date)
      try expDate.insert(db)
      return expDate
    }
  }

  func updateExpirationDate(_ expirationDate: ExpirationDate) throws {
    try writer.write { db in
      try expirationDate.update(db)
    }
  }

  func deleteExpirationDate(_ expirationDate: ExpirationDate) throws {
    try writer.write { db in
      _ = try expirationDate.delete(db)
    }
  }
}

// MARK: - Finished Items

extension AppDatabase {
  func fetchAllFinishedItems() throws -> [FinishedItem] {
    try writer.read { db in
      try FinishedItem
        .order(Column("finishedDate").desc)
        .fetchAll(db)
    }
  }

  func fetchDistinctFinishedNames() throws -> [String] {
    try writer.read { db in
      try String.fetchAll(
        db,
        sql: """
          SELECT name FROM finishedItem
          GROUP BY name
          ORDER BY MAX(finishedDate) DESC
          """
      )
    }
  }

  func deleteFinishedItem(_ item: FinishedItem) throws {
    try writer.write { db in
      _ = try item.delete(db)
    }
  }

  func observeAllFinishedItems()
    -> AsyncValueObservation<[FinishedItem]>
  {
    let observation = ValueObservation.tracking { db in
      try FinishedItem
        .order(Column("finishedDate").desc)
        .fetchAll(db)
    }
    return observation.values(in: writer)
  }
}
