// Copyright Justin Bishop, 2026

import SwiftUI

struct AddItemView: View {
  @Environment(\.dismiss) private var dismiss

  let onSave: (String, Date, Bool, Date?) -> Void

  @State private var name: String = ""
  @State private var expirationDate: Date = Date()
  @State private var flagged: Bool = false
  @State private var notificationDate: Date? = nil

  var body: some View {
    NavigationStack {
      Form {
        ItemFormFields(
          name: $name,
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
            onSave(name, expirationDate, flagged, notificationDate)
            dismiss()
          }
          .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
  }
}

#Preview {
  AddItemView { name, date, flagged, notificationDate in
    print(
      "Added: \(name) - \(date) - flagged: \(flagged) - \(String(describing: notificationDate))"
    )
  }
}
