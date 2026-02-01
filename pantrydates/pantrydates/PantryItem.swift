// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct PantryItem: Codable, Identifiable, Hashable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "pantryItem"

    var id: Int64?
    var name: String
    var expirationDate: Date
    var flagged: Bool = false
}
