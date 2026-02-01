// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let database: AppDatabase
    let itemId: Int64
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var expirationDate: Date = Date()
    @State private var flagged: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var itemExists = true

    var body: some View {
        Group {
            if itemExists {
                Form {
                    TextField("Item Name", text: $name)
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                    Toggle("Flagged", isOn: $flagged)
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
        .confirmationDialog("Delete Item", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
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
            onDismiss()
        }
    }

    private func loadItem() {
        do {
            if let item = try database.fetchItem(id: itemId) {
                name = item.name
                expirationDate = item.expirationDate
                flagged = item.flagged
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

        var updatedItem = PantryItem(id: itemId, name: trimmedName, expirationDate: expirationDate, flagged: flagged)
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
