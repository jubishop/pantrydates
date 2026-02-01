// Copyright Justin Bishop, 2026

import GRDB
import SwiftUI

struct ContentView: View {
  let database: AppDatabase

  @State private var items: [PantryItem] = []
  @State private var showingAddSheet = false
  @State private var showFlaggedOnly = false

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
  }()

  private var displayedItems: [PantryItem] {
    showFlaggedOnly ? items.filter { $0.flagged } : items
  }

  var body: some View {
    NavigationStack {
      List(displayedItems) { item in
        NavigationLink(value: item) {
          HStack {
            if item.flagged {
              Image(systemName: "flag.fill")
                .foregroundStyle(.orange)
            }
            VStack(alignment: .leading, spacing: 2) {
              Text(item.name)
              if !item.notes.isEmpty {
                Text(item.notes)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
              HStack(spacing: 4) {
                Image(systemName: "calendar")
                  .font(.caption2)
                Text(dateFormatter.string(from: item.expirationDate))
              }
              .foregroundStyle(.secondary)
              if let notificationDate = item.notificationDate {
                HStack(spacing: 4) {
                  Image(systemName: "bell")
                    .font(.caption2)
                  Text(dateFormatter.string(from: notificationDate))
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
      .task {
        do {
          for try await updatedItems in database.observeAllItems() {
            items = updatedItems
          }
        } catch {
          print("Failed to observe items: \(error)")
        }
      }
      .navigationTitle("Pantry")
      .navigationDestination(for: PantryItem.self) { item in
        if let id = item.id {
          ItemDetailView(database: database, itemId: id)
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
        AddItemView(database: database)
      }
    }
  }

  private func deleteItem(_ item: PantryItem) {
    do {
      try database.deleteItem(item)
    } catch {
      print("Failed to delete item: \(error)")
    }
  }

  private func toggleFlagged(item: PantryItem) {
    guard let id = item.id else { return }
    do {
      try database.toggleFlagged(id: id)
    } catch {
      print("Failed to toggle flagged: \(error)")
    }
  }
}
