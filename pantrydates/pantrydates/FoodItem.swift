// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct FoodItem: Codable, Identifiable, Hashable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "foodItem"

  var id: Int64?
  var name: String
  var notes: String = ""
  var expirationDate: Date
  var flagged: Bool = false
  var notificationDate: Date? = nil
  var notificationSent: Bool = false
  var refrigerated: Bool = false

  // Update auto-incremented id upon successful insertion
  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
