// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct FinishedItem: Codable, Identifiable, Hashable,
  FetchableRecord, MutablePersistableRecord
{
  static let databaseTableName = "finishedItem"

  var id: Int64?
  var name: String
  var finishedDate: Date

  init(
    id: Int64? = nil,
    name: String = "",
    finishedDate: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.finishedDate = finishedDate
  }

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
