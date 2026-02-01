// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct PantryItem: Codable, Identifiable, Hashable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "pantryItem"

  var id: Int64?
  var name: String
  var notes: String = ""
  var expirationDate: Date
  var flagged: Bool = false
  var notificationDate: Date? = nil
  var notificationSent: Bool = false

  // Update auto-incremented id upon successful insertion
  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
