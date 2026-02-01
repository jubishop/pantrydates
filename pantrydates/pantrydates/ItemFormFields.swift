// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemFormFields: View {
  @Binding var item: FoodItem

  var body: some View {
    TextField("Item Name", text: $item.name)
    TextField("Notes", text: $item.notes)
    DatePicker("Expiration Date", selection: $item.expirationDate, displayedComponents: .date)
    Toggle("Flagged", isOn: $item.flagged)
    Toggle("Refrigerated", isOn: $item.refrigerated)

    Section {
      if let date = item.notificationDate {
        DatePicker(
          "Notification Date",
          selection: Binding(
            get: { date },
            set: { item.notificationDate = $0 }
          ),
          displayedComponents: .date
        )
        Button("Remove Notification", role: .destructive) {
          item.notificationDate = nil
        }
      } else {
        Button("Add Notification Date") {
          item.notificationDate = item.expirationDate
        }
      }
    } header: {
      Label("Notification", systemImage: "bell")
    }
  }
}
