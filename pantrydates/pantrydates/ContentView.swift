// Copyright Justin Bishop, 2026

import SwiftUI

struct ContentView: View {
  let database: AppDatabase

  @State private var items: [PantryItem] = []
  @State private var showingAddSheet = false
  @State private var showFlaggedOnly = false

  private var displayedItems: [PantryItem] {
    showFlaggedOnly ? items.filter { $0.flagged } : items
  }

  var body: some View {
    NavigationStack {
      List {
        ForEach(displayedItems) { item in
          NavigationLink(value: item) {
            HStack {
              if item.flagged {
                Image(systemName: "flag.fill")
                  .foregroundStyle(.orange)
              }
              Text(item.name)
              Spacer()
              VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                  Image(systemName: "calendar")
                    .font(.caption2)
                  Text(item.expirationDate, style: .date)
                }
                .foregroundStyle(.secondary)
                if let notificationDate = item.notificationDate {
                  HStack(spacing: 4) {
                    Image(systemName: "bell")
                      .font(.caption2)
                    Text(notificationDate, style: .date)
                  }
                  .foregroundStyle(.blue)
                  .font(.caption)
                }
              }
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
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              deleteItem(item)
            } label: {
              Image(systemName: "trash")
            }
          }
        }
      }
      .navigationTitle("Pantry")
      .navigationDestination(for: PantryItem.self) { item in
        if let id = item.id {
          ItemDetailView(database: database, itemId: id, onDismiss: loadItems)
        }
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            showFlaggedOnly.toggle()
          } label: {
            Image(systemName: showFlaggedOnly ? "flag.fill" : "flag")
          }
          .tint(showFlaggedOnly ? .orange : nil)
        }
        ToolbarItem(placement: .primaryAction) {
          Button {
            showingAddSheet = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showingAddSheet) {
        AddItemView { name, date, flagged, notificationDate in
          addItem(name: name, date: date, flagged: flagged, notificationDate: notificationDate)
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

  private func addItem(name: String, date: Date, flagged: Bool, notificationDate: Date?) {
    var newItem = PantryItem(
      id: nil,
      name: name.trimmingCharacters(in: .whitespacesAndNewlines),
      expirationDate: date,
      flagged: flagged,
      notificationDate: notificationDate
    )
    do {
      try database.saveItem(&newItem)
      loadItems()
    } catch {
      print("Failed to save item: \(error)")
    }
  }

  private func deleteItem(_ item: PantryItem) {
    do {
      try database.deleteItem(item)
      loadItems()
    } catch {
      print("Failed to delete item: \(error)")
    }
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
