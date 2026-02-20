// Copyright Justin Bishop, 2026

import Foundation
import GRDB

struct FinishedItem: Codable, Identifiable, Hashable,
  FetchableRecord, MutablePersistableRecord
{
  static let databaseTableName = "finishedItem"

  var id: Int64?
  var name: String
  var notes: String
  var finishedDate: Date
  var flagged: Bool
  var refrigerated: Bool
  var symbolName: String

  init(
    id: Int64? = nil,
    name: String = "",
    notes: String = "",
    finishedDate: Date = Date(),
    flagged: Bool = false,
    refrigerated: Bool = false,
    symbolName: String = "utensils"
  ) {
    self.id = id
    self.name = name
    self.notes = notes
    self.finishedDate = finishedDate
    self.flagged = flagged
    self.refrigerated = refrigerated
    self.symbolName = symbolName
  }

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
