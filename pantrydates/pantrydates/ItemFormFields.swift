// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemFormFields: View {
  @Binding var name: String
  @Binding var notes: String
  @Binding var expirationDate: Date
  @Binding var flagged: Bool
  @Binding var refrigerated: Bool
  @Binding var notificationDate: Date?

  var body: some View {
    TextField("Item Name", text: $name)
    TextField("Notes", text: $notes)
    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
    Toggle("Flagged", isOn: $flagged)
    Toggle("Refrigerated", isOn: $refrigerated)

    Section {
      if let date = notificationDate {
        DatePicker(
          "Notification Date",
          selection: Binding(
            get: { date },
            set: { notificationDate = $0 }
          ),
          displayedComponents: .date
        )
        Button("Remove Notification", role: .destructive) {
          notificationDate = nil
        }
      } else {
        Button("Add Notification Date") {
          notificationDate = expirationDate
        }
      }
    } header: {
      Label("Notification", systemImage: "bell")
    }
  }
}
