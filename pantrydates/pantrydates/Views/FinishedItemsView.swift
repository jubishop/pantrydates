// Copyright Justin Bishop, 2026

import GRDB
import SwiftUI

struct FinishedItemsView: View {
  let database: AppDatabase

  @State private var finishedItems: [FinishedItem] = []
  @State private var itemToReAdd: FinishedItem?

  var body: some View {
    NavigationStack {
      List {
        ForEach(finishedItems) { item in
          FoodItemRow(
            symbolName: item.symbolName,
            flagged: item.flagged,
            name: item.name,
            notes: item.notes,
            date: item.finishedDate,
            dateColor: .secondary,
            dateBold: false
          )
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              deleteFinishedItem(item)
            } label: {
              Image(systemName: "trash")
            }
          }
          .swipeActions(edge: .leading) {
            Button {
              itemToReAdd = item
            } label: {
              Image(systemName: "plus.circle")
            }
            .tint(.blue)
          }
        }
      }
      .task {
        do {
          for try await items
            in database.observeAllFinishedItems()
          {
            finishedItems = items
          }
        } catch {
          print(
            "Failed to observe finished items: \(error)"
          )
        }
      }
      .navigationTitle("Finished")
      .sheet(item: $itemToReAdd) { finished in
        AddItemView(
          database: database,
          initialItem: FoodItem(
            name: finished.name,
            notes: finished.notes,
            flagged: finished.flagged,
            refrigerated: finished.refrigerated,
            symbolName: finished.symbolName
          )
        )
      }
    }
  }

  private func deleteFinishedItem(
    _ item: FinishedItem
  ) {
    do {
      try database.deleteFinishedItem(item)
    } catch {
      print("Failed to delete finished item: \(error)")
    }
  }
}
