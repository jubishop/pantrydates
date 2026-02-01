// Copyright Justin Bishop, 2026

import SwiftUI

struct AddItemView: View {
  @Environment(\.dismiss) private var dismiss

  let database: AppDatabase

  @State private var name: String = ""
  @State private var notes: String = ""
  @State private var expirationDate: Date = Date()
  @State private var flagged: Bool = false
  @State private var notificationDate: Date? = nil

  var body: some View {
    NavigationStack {
      Form {
        ItemFormFields(
          name: $name,
          notes: $notes,
          expirationDate: $expirationDate,
          flagged: $flagged,
          notificationDate: $notificationDate
        )
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
          .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
  }

  private func saveItem() {
    var newItem = FoodItem(
      id: nil,
      name: name.trimmingCharacters(in: .whitespacesAndNewlines),
      notes: notes,
      expirationDate: expirationDate,
      flagged: flagged,
      notificationDate: notificationDate
    )
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
