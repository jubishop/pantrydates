// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemFormFields: View {
  @Binding var item: FoodItem
  var autoFocusName: Bool = false
  var onNameFocusLost: (() -> Void)?

  @FocusState private var isNameFocused: Bool

  var body: some View {
    TextField("Item Name", text: $item.name)
      .focused($isNameFocused)
      .onAppear {
        if autoFocusName {
          isNameFocused = true
        }
      }
      .onChange(of: isNameFocused) { _, focused in
        if !focused {
          onNameFocusLost?()
        }
      }
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
