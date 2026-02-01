// Copyright Justin Bishop, 2026

import SwiftUI

struct AddItemView: View {
  @Environment(\.dismiss) private var dismiss

  let database: AppDatabase

  @State private var item = FoodItem()
  @State private var userDidSelectSymbol = false
  @State private var isGeneratingSymbol = false

  var body: some View {
    NavigationStack {
      Form {
        SymbolPickerSection(
          symbolName: $item.symbolName,
          userDidSelectSymbol: $userDidSelectSymbol,
          itemName: item.name,
          isGeneratingSymbol: isGeneratingSymbol,
          onSuggestSymbol: suggestSymbol
        )
        ItemFormFields(item: $item, autoFocusName: true)
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

  private func saveItem() {
    var newItem = item
    newItem.name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    newItem.notes = item.notes.trimmingCharacters(in: .whitespacesAndNewlines)
    do {
      let id = try database.saveItem(&newItem)
      // Auto-generate symbol in background only if user never selected one
      if !userDidSelectSymbol {
        let name = newItem.name
        Task {
          if let symbol = await SymbolService.shared.suggestSymbol(for: name) {
            try? database.updateSymbol(id: id, symbolName: symbol)
          }
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
