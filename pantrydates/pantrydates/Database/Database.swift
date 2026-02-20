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

// MARK: - Database Access

extension AppDatabase {
  func fetchAllItems() throws -> [FoodItem] {
    try writer.read { db in
      try FoodItem.order(Column("expirationDate").asc).fetchAll(db)
    }
  }

  func fetchItem(id: Int64) throws -> FoodItem? {
    try writer.read { db in
      try FoodItem.fetchOne(db, key: id)
    }
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

  func observeAllItems() -> AsyncValueObservation<[FoodItem]> {
    let observation = ValueObservation.tracking { db in
      try FoodItem.order(Column("expirationDate").asc).fetchAll(db)
    }
    return observation.values(in: writer)
  }

  func updateSymbol(id: Int64, symbolName: String) throws {
    try writer.write { db in
      if var item = try FoodItem.fetchOne(db, key: id) {
        item.symbolName = symbolName
        try item.update(db)
      }
    }
  }

  func finishItem(_ item: FoodItem) throws {
    try writer.write { db in
      var finished = FinishedItem(
        name: item.name,
        notes: item.notes,
        finishedDate: Date(),
        flagged: item.flagged,
        refrigerated: item.refrigerated,
        symbolName: item.symbolName
      )
      try finished.insert(db)
      _ = try item.delete(db)
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

}
