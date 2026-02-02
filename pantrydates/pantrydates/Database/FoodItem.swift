// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct FoodItem: Codable, Identifiable, Hashable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "foodItem"

  var id: Int64?
  var name: String
  var notes: String
  var expirationDate: Date
  var flagged: Bool
  var notificationDate: Date?
  var notificationSent: Bool
  var refrigerated: Bool
  var symbolName: String

  init(
    id: Int64? = nil,
    name: String = "",  // Must be set before saving
    notes: String = "",
    expirationDate: Date = Date(),
    flagged: Bool = false,
    notificationDate: Date? = nil,
    notificationSent: Bool = false,
    refrigerated: Bool = false,
    symbolName: String = "utensils"
  ) {
    self.id = id
    self.name = name
    self.notes = notes
    self.expirationDate = expirationDate
    self.flagged = flagged
    self.notificationDate = notificationDate
    self.notificationSent = notificationSent
    self.refrigerated = refrigerated
    self.symbolName = symbolName
  }

  // Update auto-incremented id upon successful insertion
  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
