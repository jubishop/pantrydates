// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct ExpirationDate: Codable, Identifiable, Hashable,
  FetchableRecord, MutablePersistableRecord
{
  static let databaseTableName = "expirationDate"

  static let foodItem = belongsTo(FoodItem.self)

  var id: Int64?
  var foodItemId: Int64
  var date: Date

  init(
    id: Int64? = nil,
    foodItemId: Int64,
    date: Date = Date()
  ) {
    self.id = id
    self.foodItemId = foodItemId
    self.date = date
  }

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
