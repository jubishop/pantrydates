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
      let id = try database.saveItem(&newItem)
      // Auto-generate symbol in background
      let name = newItem.name
      Task {
        if let symbol = await SymbolService.shared.suggestSymbol(for: name) {
          try? database.updateSymbol(id: id, symbolName: symbol)
        }
      }
    } catch {
      print("Failed to save item: \(error)")
    }
  }
}

#Preview {
  AddItemView(database: try! AppDatabase.makeEmpty())
}
