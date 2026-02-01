// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemDetailView: View {
  @Environment(\.dismiss) private var dismiss

  let database: AppDatabase
  let itemId: Int64

  @State private var name: String = ""
  @State private var notes: String = ""
  @State private var expirationDate: Date = Date()
  @State private var flagged: Bool = false
  @State private var notificationDate: Date? = nil
  @State private var originalNotificationDate: Date? = nil
  @State private var showDeleteConfirmation = false
  @State private var itemExists = true

  var body: some View {
    Group {
      if itemExists {
        Form {
          ItemFormFields(
            name: $name,
            notes: $notes,
            expirationDate: $expirationDate,
            flagged: $flagged,
            notificationDate: $notificationDate
          )
        }
      } else {
        ContentUnavailableView("Item Not Found", systemImage: "questionmark.circle")
      }
    }
    .navigationTitle("Edit Item")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if itemExists {
        ToolbarItem(placement: .destructiveAction) {
          Button(role: .destructive) {
            showDeleteConfirmation = true
          } label: {
            Image(systemName: "trash")
          }
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
    .task {
      loadItem()
    }
    .onDisappear {
      saveChanges()
    }
  }

  private func loadItem() {
    do {
      if let item = try database.fetchItem(id: itemId) {
        name = item.name
        notes = item.notes
        expirationDate = item.expirationDate
        flagged = item.flagged
        notificationDate = item.notificationDate
        originalNotificationDate = item.notificationDate
      } else {
        itemExists = false
      }
    } catch {
      print("Failed to load item: \(error)")
      itemExists = false
    }
  }

  private func saveChanges() {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty, itemExists else { return }

    // Reset notificationSent if the notification date changed
    let notificationDateChanged = notificationDate != originalNotificationDate
    let notificationSent = notificationDateChanged ? false : nil  // nil means keep existing value

    var updatedItem = PantryItem(
      id: itemId,
      name: trimmedName,
      notes: notes,
      expirationDate: expirationDate,
      flagged: flagged,
      notificationDate: notificationDate,
      notificationSent: notificationSent ?? false
    )

    // If date didn't change, we need to preserve the existing notificationSent value
    if !notificationDateChanged {
      do {
        if let existingItem = try database.fetchItem(id: itemId) {
          updatedItem.notificationSent = existingItem.notificationSent
        }
      } catch {
        print("Failed to fetch existing item: \(error)")
      }
    }

    do {
      try database.saveItem(&updatedItem)
    } catch {
      print("Failed to save item: \(error)")
    }
  }

  private func deleteItem() {
    do {
      try database.deleteItem(id: itemId)
      dismiss()
    } catch {
      print("Failed to delete item: \(error)")
    }
  }
}
