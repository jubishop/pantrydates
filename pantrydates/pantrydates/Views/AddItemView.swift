// Copyright Justin Bishop, 2026

import SwiftUI

struct AddItemView: View {
  @Environment(\.dismiss) private var dismiss

  let database: AppDatabase

  @State private var item = FoodItem()
  @State private var userDidSelectSymbol = false
  @State private var isGeneratingSymbol = false
  @State private var lastGeneratedName = ""
  @FocusState private var isNameFocused: Bool

  var body: some View {
    NavigationStack {
      Form {
        SymbolPicker(
          symbolName: $item.symbolName,
          userDidSelectSymbol: $userDidSelectSymbol,
          itemName: item.name,
          isGeneratingSymbol: isGeneratingSymbol,
          onSuggestSymbol: suggestSymbol
        )
        ItemFormFields(item: $item) {
          TextField("Item Name", text: $item.name)
            .focused($isNameFocused)
            .onAppear { isNameFocused = true }
            .onChange(of: isNameFocused) { _, focused in
              if !focused { handleNameFocusLost() }
            }
        }
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

  private func handleNameFocusLost() {
    let trimmedName = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !userDidSelectSymbol,
      !trimmedName.isEmpty,
      trimmedName != lastGeneratedName
    else { return }

    lastGeneratedName = trimmedName
    isGeneratingSymbol = true
    Task {
      if let symbol = await SymbolService.shared.suggestSymbol(for: trimmedName) {
        item.symbolName = symbol
      }
      isGeneratingSymbol = false
    }
  }

  private func suggestSymbol() {
    let name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty else { return }

    lastGeneratedName = name
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
      // Auto-generate symbol if not manually selected and name not yet processed
      if !userDidSelectSymbol && newItem.name != lastGeneratedName {
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
