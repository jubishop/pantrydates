// Copyright Justin Bishop, 2026

import SwiftUI

struct ContentView: View {
    let database: AppDatabase

    @State private var items: [PantryItem] = []
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        HStack {
                            if item.flagged {
                                Image(systemName: "flag.fill")
                                    .foregroundStyle(.orange)
                            }
                            Text(item.name)
                            Spacer()
                            Text(item.expirationDate, style: .date)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggleFlagged(item: item)
                        } label: {
                            Image(systemName: item.flagged ? "flag.slash" : "flag")
                        }
                        .tint(.orange)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Pantry")
            .navigationDestination(for: PantryItem.self) { item in
                if let id = item.id {
                    ItemDetailView(database: database, itemId: id, onDismiss: loadItems)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemView { name, date in
                    addItem(name: name, date: date)
                }
            }
            .onAppear {
                loadItems()
            }
        }
    }

    private func loadItems() {
        do {
            items = try database.fetchAllItems()
        } catch {
            print("Failed to load items: \(error)")
        }
    }

    private func addItem(name: String, date: Date) {
        var newItem = PantryItem(
            id: nil,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            expirationDate: date
        )
        do {
            try database.saveItem(&newItem)
            loadItems()
        } catch {
            print("Failed to save item: \(error)")
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            do {
                try database.deleteItem(item)
            } catch {
                print("Failed to delete item: \(error)")
            }
        }
        loadItems()
    }

    private func toggleFlagged(item: PantryItem) {
        guard let id = item.id else { return }
        do {
            try database.toggleFlagged(id: id)
            loadItems()
        } catch {
            print("Failed to toggle flagged: \(error)")
        }
    }
}
