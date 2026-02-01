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

  func saveItem(_ item: inout FoodItem) throws {
    try writer.write { db in
      try item.save(db)
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

  func fetchItemsPendingNotification() throws -> [FoodItem] {
    try writer.read { db in
      try FoodItem
        .filter(Column("notificationDate") != nil)
        .filter(Column("notificationSent") == false)
        .filter(Column("notificationDate") <= Date())
        .fetchAll(db)
    }
  }

  func markNotificationSent(id: Int64) throws {
    try writer.write { db in
      if var item = try FoodItem.fetchOne(db, key: id) {
        item.notificationSent = true
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
}
