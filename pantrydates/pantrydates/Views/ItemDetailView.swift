// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemDetailView: View {
  @Environment(\.dismiss) private var dismiss

  let database: AppDatabase

  @State private var info: FoodItemInfo
  @State private var originalName: String
  @State private var newDate = Date()
  @State private var showDeleteConfirmation = false
  @State private var isGeneratingSymbol = false
  @State private var userDidSelectSymbol = false
  @State private var wasDeleted = false

  init(database: AppDatabase, info: FoodItemInfo) {
    self.database = database
    _info = State(initialValue: info)
    _originalName = State(initialValue: info.foodItem.name)
  }

  var body: some View {
    Form {
      SymbolPicker(
        symbolName: $info.foodItem.symbolName,
        userDidSelectSymbol: $userDidSelectSymbol,
        itemName: info.foodItem.name,
        flagged: info.foodItem.flagged,
        isGeneratingSymbol: isGeneratingSymbol,
        onSuggestSymbol: suggestSymbol
      )
      ItemFormFields(item: $info.foodItem)

      Section("Expiration Dates") {
        ForEach(info.sortedDates) { expDate in
          DatePicker(
            expDate.date.formatted(date: .abbreviated, time: .omitted),
            selection: bindingForDate(expDate),
            displayedComponents: .date
          )
          .foregroundStyle(dateColor(for: expDate.date))
          .fontWeight(
            isPastExpired(expDate.date) ? .bold : .regular
          )
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              removeDate(expDate)
            } label: {
              Image(systemName: "trash")
            }
          }
        }
        HStack {
          DatePicker("New Date", selection: $newDate, displayedComponents: .date)
          Button {
            addDate()
          } label: {
            Image(systemName: "plus.circle.fill")
              .foregroundStyle(.green)
          }
          .buttonStyle(.borderless)
        }
      }
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

  private func bindingForDate(
    _ expDate: ExpirationDate
  ) -> Binding<Date> {
    Binding(
      get: {
        guard
          let match = info.expirationDates.first(
            where: { $0.id == expDate.id }
          )
        else {
          fatalError("Expiration date not found in array")
        }
        return match.date
      },
      set: { newDate in
        guard
          let index = info.expirationDates.firstIndex(
            where: { $0.id == expDate.id }
          )
        else {
          fatalError("Expiration date not found in array")
        }
        info.expirationDates[index].date = newDate
      }
    )
  }

  private func addDate() {
    guard let id = info.id else { return }
    do {
      let expDate = try database.addExpirationDate(foodItemId: id, date: newDate)
      info.expirationDates.append(expDate)
    } catch {
      print("Failed to add date: \(error)")
    }
  }

  private func removeDate(_ expDate: ExpirationDate) {
    if info.expirationDates.count <= 1 {
      showDeleteConfirmation = true
      return
    }
    do {
      try database.deleteExpirationDate(expDate)
      info.expirationDates.removeAll { $0.id == expDate.id }
    } catch {
      print("Failed to remove date: \(error)")
    }
  }

  private func suggestSymbol() {
    let name = info.foodItem.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty else { return }

    isGeneratingSymbol = true
    Task {
      if let symbol = await SymbolService.shared.suggestSymbol(for: name) {
        info.foodItem.symbolName = symbol
        userDidSelectSymbol = true
      }
      isGeneratingSymbol = false
    }
  }

  private func saveChanges() {
    guard !wasDeleted else { return }

    let trimmedName = info.foodItem.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty else { return }

    let nameChanged = trimmedName != originalName

    var updatedItem = info.foodItem
    updatedItem.name = trimmedName
    updatedItem.notes = info.foodItem.notes.trimmingCharacters(in: .whitespacesAndNewlines)

    do {
      let id = try database.saveItem(&updatedItem)
      for expDate in info.expirationDates {
        try database.updateExpirationDate(expDate)
      }
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
    guard let id = info.id else { fatalError("Editing unsaved item?") }
    do {
      try database.deleteItem(id: id)
      wasDeleted = true
      dismiss()
    } catch {
      print("Failed to delete item: \(error)")
    }
  }
}
