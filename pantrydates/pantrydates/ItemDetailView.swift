// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemDetailView: View {
  @Environment(\.dismiss) private var dismiss

  let database: AppDatabase

  @State private var item: FoodItem
  @State private var originalNotificationDate: Date?
  @State private var showDeleteConfirmation = false

  init(database: AppDatabase, item: FoodItem) {
    self.database = database
    _item = State(initialValue: item)
    _originalNotificationDate = State(initialValue: item.notificationDate)
  }

  var body: some View {
    Form {
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

  private func saveChanges() {
    let trimmedName = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else { return }

    // Reset notificationSent if the notification date changed
    let notificationDateChanged = item.notificationDate != originalNotificationDate

    var updatedItem = item
    updatedItem.name = trimmedName
    updatedItem.notes = item.notes.trimmingCharacters(in: .whitespacesAndNewlines)

    if notificationDateChanged {
      updatedItem.notificationSent = false
    }

    do {
      try database.saveItem(&updatedItem)
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
