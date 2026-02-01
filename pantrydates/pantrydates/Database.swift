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
    func fetchAllItems() throws -> [PantryItem] {
        try writer.read { db in
            try PantryItem.order(Column("expirationDate").asc).fetchAll(db)
        }
    }

    func fetchItem(id: Int64) throws -> PantryItem? {
        try writer.read { db in
            try PantryItem.fetchOne(db, key: id)
        }
    }

    func saveItem(_ item: inout PantryItem) throws {
        try writer.write { db in
            try item.save(db)
        }
    }

    func deleteItem(_ item: PantryItem) throws {
        try writer.write { db in
            _ = try item.delete(db)
        }
    }

    func deleteItem(id: Int64) throws {
        try writer.write { db in
            _ = try PantryItem.deleteOne(db, key: id)
        }
    }

    func toggleFlagged(id: Int64) throws {
        try writer.write { db in
            if var item = try PantryItem.fetchOne(db, key: id) {
                item.flagged.toggle()
                try item.update(db)
            }
        }
    }
}
