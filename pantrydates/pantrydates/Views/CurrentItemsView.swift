// Copyright Justin Bishop, 2026

import GRDB
import SwiftUI

extension URL: @retroactive Identifiable {
  public var id: String { absoluteString }
}

struct CurrentItemsView: View {
  let database: AppDatabase

  @State private var itemInfos: [FoodItemInfo] = []
  @State private var showingAddSheet = false
  @State private var showFlaggedOnly = false
  @State private var filterText = ""
  @State private var exportedFileURL: URL?

  private var pantryInfos: [FoodItemInfo] {
    filteredInfos(refrigerated: false)
  }

  private var fridgeInfos: [FoodItemInfo] {
    filteredInfos(refrigerated: true)
  }

  private func filteredInfos(
    refrigerated: Bool
  ) -> [FoodItemInfo] {
    var result =
      showFlaggedOnly ? itemInfos.filter { $0.foodItem.flagged } : itemInfos
    if !filterText.isEmpty {
      result = result.filter {
        $0.foodItem.name.localizedCaseInsensitiveContains(filterText)
      }
    }
    return result.filter {
      $0.foodItem.refrigerated == refrigerated
    }
  }

  var body: some View {
    NavigationStack {
      List {
        Section("Pantry") {
          ForEach(pantryInfos) { info in
            itemRow(info)
          }
        }
        Section("Fridge") {
          ForEach(fridgeInfos) { info in
            itemRow(info)
          }
        }
      }
      .safeAreaInset(edge: .top) {
        FilterField(text: $filterText)
      }
      .task {
        do {
          for try await updatedInfos
            in database.observeAllItemInfos()
          {
            itemInfos = updatedInfos
          }
        } catch {
          print("Failed to observe items: \(error)")
        }
      }
      .navigationTitle("Food")
      .navigationDestination(for: FoodItemInfo.self) { info in
        ItemDetailView(database: database, info: info)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            showFlaggedOnly.toggle()
          } label: {
            Image(
              systemName: showFlaggedOnly
                ? "flag.fill" : "flag"
            )
          }
          .tint(showFlaggedOnly ? .orange : nil)
        }
        ToolbarItem(placement: .primaryAction) {
          Button {
            showingAddSheet = true
          } label: {
            Image(systemName: "plus")
          }
        }
        if database.databaseURL != nil {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              exportDatabase()
            } label: {
              Image(systemName: "square.and.arrow.up")
            }
          }
        }
      }
      .sheet(isPresented: $showingAddSheet) {
        AddItemView(database: database)
      }
      .sheet(item: $exportedFileURL) { url in
        ActivityView(activityItems: [url])
      }
    }
  }

  private func itemRow(_ info: FoodItemInfo) -> some View {
    guard let date = info.mostImminentDate else {
      fatalError("Item has no expiration dates")
    }
    return NavigationLink(value: info) {
      FoodItemRow(
        symbolName: info.foodItem.symbolName,
        flagged: info.foodItem.flagged,
        name: info.foodItem.name,
        notes: info.foodItem.notes,
        date: date,
        dateColor: dateColor(for: date),
        dateBold: isPastExpired(date)
      )
    }
    .swipeActions(edge: .leading) {
      Button {
        toggleFlagged(info: info)
      } label: {
        Image(
          systemName: info.foodItem.flagged
            ? "flag.slash" : "flag"
        )
      }
      .tint(.orange)
    }
    .swipeActions(edge: .trailing) {
      Button {
        finishItemDate(info)
      } label: {
        Image(systemName: "checkmark.circle")
      }
      .tint(.green)
      Button(role: .destructive) {
        deleteItem(info.foodItem)
      } label: {
        Image(systemName: "trash")
      }
    }
  }

  private func finishItemDate(_ info: FoodItemInfo) {
    do {
      try database.finishItemDate(info)
    } catch {
      print("Failed to finish item: \(error)")
    }
  }

  private func deleteItem(_ item: FoodItem) {
    do {
      try database.deleteItem(item)
    } catch {
      print("Failed to delete item: \(error)")
    }
  }

  private func exportDatabase() {
    guard let sourceURL = database.databaseURL else { return }
    let tempDir = FileManager.default.temporaryDirectory
    let destURL = tempDir.appendingPathComponent(
      "pantrydates.sqlite"
    )
    try? FileManager.default.removeItem(at: destURL)
    do {
      try FileManager.default.copyItem(
        at: sourceURL,
        to: destURL
      )
      exportedFileURL = destURL
    } catch {
      print("Failed to export database: \(error)")
    }
  }

  private func toggleFlagged(info: FoodItemInfo) {
    guard let id = info.id else { return }
    do {
      try database.toggleFlagged(id: id)
    } catch {
      print("Failed to toggle flagged: \(error)")
    }
  }

}
