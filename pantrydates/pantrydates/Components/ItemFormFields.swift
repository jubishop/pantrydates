// Copyright Justin Bishop, 2026

import SwiftUI

struct ItemFormFields<NameField: View>: View {
  @Binding var item: FoodItem
  let nameField: () -> NameField

  init(item: Binding<FoodItem>, @ViewBuilder nameField: @escaping () -> NameField) {
    self._item = item
    self.nameField = nameField
  }

  var body: some View {
    nameField()
    TextField("Notes", text: $item.notes)
    DatePicker("Expiration Date", selection: $item.expirationDate, displayedComponents: .date)
    Toggle("Flagged", isOn: $item.flagged)
    Toggle("Refrigerated", isOn: $item.refrigerated)
  }
}

extension ItemFormFields where NameField == TextField<Text> {
  init(item: Binding<FoodItem>) {
    self.init(item: item) {
      TextField("Item Name", text: item.name)
    }
  }
}
