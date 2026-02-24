// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct FoodItem: Codable, Identifiable, Hashable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "foodItem"

  static let expirationDates = hasMany(ExpirationDate.self)

  var id: Int64?
  var name: String
  var notes: String
  var flagged: Bool
  var refrigerated: Bool
  var symbolName: String

  init(
    id: Int64? = nil,
    name: String = "",
    notes: String = "",
    flagged: Bool = false,
    refrigerated: Bool = false,
    symbolName: String = "utensils"
  ) {
    self.id = id
    self.name = name
    self.notes = notes
    self.flagged = flagged
    self.refrigerated = refrigerated
    self.symbolName = symbolName
  }

  // Update auto-incremented id upon successful insertion
  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}

struct FoodItemInfo: Decodable, Identifiable, FetchableRecord, Hashable {
  var id: Int64? { foodItem.id }
  var foodItem: FoodItem
  var expirationDates: [ExpirationDate]

  var sortedDates: [ExpirationDate] {
    expirationDates.sorted { $0.date < $1.date }
  }

  var mostImminentDate: Date? {
    sortedDates.first?.date
  }
}
