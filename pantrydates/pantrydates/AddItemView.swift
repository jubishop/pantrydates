// Copyright Justin Bishop, 2026

import SwiftUI

struct AddItemView: View {
  @Environment(\.dismiss) private var dismiss

  let database: AppDatabase

  @State private var item = FoodItem()

  var body: some View {
    NavigationStack {
      Form {
        ItemFormFields(item: $item)
      }
      .navigationTitle("New Item")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveItem()
            dismiss()
          }
          .disabled(item.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
  }

  private func saveItem() {
    var newItem = item
    newItem.name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    newItem.notes = item.notes.trimmingCharacters(in: .whitespacesAndNewlines)
    do {
      try database.saveItem(&newItem)
    } catch {
      print("Failed to save item: \(error)")
    }
  }
}

#Preview {
  AddItemView(database: try! AppDatabase.makeEmpty())
}
