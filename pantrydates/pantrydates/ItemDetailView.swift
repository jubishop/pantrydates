// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemDetailView: View {
  @Environment(\.dismiss) private var dismiss

  let database: AppDatabase

  @State private var item: FoodItem
  @State private var originalName: String
  @State private var originalNotificationDate: Date?
  @State private var showDeleteConfirmation = false
  @State private var isGeneratingSymbol = false
  @State private var userDidSelectSymbol = false

  init(database: AppDatabase, item: FoodItem) {
    self.database = database
    _item = State(initialValue: item)
    _originalName = State(initialValue: item.name)
    _originalNotificationDate = State(initialValue: item.notificationDate)
  }

  var body: some View {
    Form {
      SymbolPickerSection(
        symbolName: $item.symbolName,
        userDidSelectSymbol: $userDidSelectSymbol,
        itemName: item.name,
        isGeneratingSymbol: isGeneratingSymbol,
        onSuggestSymbol: suggestSymbol
      )
      ItemFormFields(item: $item)
    }
    .navigationTitle("Edit Item")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .destructiveAction) {
        Button(role: .destructive) {
          showDeleteConfirmation = true
        } label: {
          Image(systemName: "trash")
        }
      }
    }
    .confirmationDialog(
      "Delete Item",
      isPresented: $showDeleteConfirmation,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        deleteItem()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Are you sure you want to delete this item?")
    }
    .onDisappear {
      saveChanges()
    }
  }

  private func suggestSymbol() {
    let name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty else { return }

    isGeneratingSymbol = true
    Task {
      if let symbol = await SymbolService.shared.suggestSymbol(for: name) {
        item.symbolName = symbol
        userDidSelectSymbol = true
      }
      isGeneratingSymbol = false
    }
  }

  private func saveChanges() {
    let trimmedName = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else { return }

    let nameChanged = trimmedName != originalName
    let notificationDateChanged = item.notificationDate != originalNotificationDate

    var updatedItem = item
    updatedItem.name = trimmedName
    updatedItem.notes = item.notes.trimmingCharacters(in: .whitespacesAndNewlines)

    if notificationDateChanged {
      updatedItem.notificationSent = false
    }

    do {
      let id = try database.saveItem(&updatedItem)
      // Auto-generate new symbol if name changed and user didn't manually select one
      if nameChanged && !userDidSelectSymbol {
        Task {
          if let symbol = await SymbolService.shared.suggestSymbol(for: trimmedName) {
            try? database.updateSymbol(id: id, symbolName: symbol)
          }
        }
      }
    } catch {
      print("Failed to save item: \(error)")
    }
  }

  private func deleteItem() {
    guard let id = item.id else { fatalError("Editing unsaved item?") }
    do {
      try database.deleteItem(id: id)
      dismiss()
    } catch {
      print("Failed to delete item: \(error)")
    }
  }
}
