// Copyright Justin Bishop, 2026

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (String, Date) -> Void

    @State private var name: String = ""
    @State private var expirationDate: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item Name", text: $name)
                DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
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
                        onSave(name, expirationDate)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddItemView { name, date in
        print("Added: \(name) - \(date)")
    }
}
