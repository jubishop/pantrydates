// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let database: AppDatabase
    let itemId: Int64
    let onDelete: () -> Void

    @State private var item: PantryItem?
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedDate: Date = Date()
    @State private var showDeleteConfirmation = false

    var body: some View {
        Group {
            if let item {
                Form {
                    if isEditing {
                        Section {
                            TextField("Item Name", text: $editedName)
                            DatePicker("Expiration Date", selection: $editedDate, displayedComponents: .date)
                        }
                    } else {
                        Section("Name") {
                            Text(item.name)
                        }
                        Section("Expiration Date") {
                            Text(item.expirationDate, style: .date)
                        }
                    }
                }
            } else {
                ContentUnavailableView("Item Not Found", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle(item?.name ?? "Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if item != nil {
                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("Done") {
                            saveChanges()
                        }
                        .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("Edit") {
                            startEditing()
                        }
                    }
                }
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
    }

    private func loadItem() {
        do {
            item = try database.fetchItem(id: itemId)
        } catch {
            print("Failed to load item: \(error)")
        }
    }

    private func startEditing() {
        guard let item else { return }
        editedName = item.name
        editedDate = item.expirationDate
        isEditing = true
    }

    private func saveChanges() {
        guard var updatedItem = item else { return }
        updatedItem.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.expirationDate = editedDate

        do {
            try database.saveItem(&updatedItem)
            item = updatedItem
            isEditing = false
        } catch {
            print("Failed to save item: \(error)")
        }
    }

    private func deleteItem() {
        guard let item else { return }
        do {
            try database.deleteItem(item)
            onDelete()
            dismiss()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
}
