// Copyright Justin Bishop, 2026

import GRDB
import SwiftUI

struct ContentView: View {
  let database: AppDatabase

  @State private var items: [FoodItem] = []
  @State private var showingAddSheet = false
  @State private var showFlaggedOnly = false

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
  }()

  private var pantryItems: [FoodItem] {
    let filtered = showFlaggedOnly ? items.filter { $0.flagged } : items
    return filtered.filter { !$0.refrigerated }
  }

  private var fridgeItems: [FoodItem] {
    let filtered = showFlaggedOnly ? items.filter { $0.flagged } : items
    return filtered.filter { $0.refrigerated }
  }

  var body: some View {
    NavigationStack {
      List {
        Section("Pantry") {
          ForEach(pantryItems) { item in
            itemRow(item)
          }
        }
        Section("Fridge") {
          ForEach(fridgeItems) { item in
            itemRow(item)
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
      .navigationTitle("Food")
      .navigationDestination(for: FoodItem.self) { item in
        ItemDetailView(database: database, item: item)
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

  @ViewBuilder
  private func itemRow(_ item: FoodItem) -> some View {
    NavigationLink(value: item) {
      HStack {
        FoodIconView(name: item.symbolName, size: 24)
          .foregroundStyle(item.flagged ? .orange : .secondary)
        VStack(alignment: .leading, spacing: 2) {
          Text(item.name)
          if !item.notes.isEmpty {
            Text(item.notes)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        Spacer()
        HStack(spacing: 4) {
          Image(systemName: "calendar")
            .font(.caption2)
          Text(dateFormatter.string(from: item.expirationDate))
            .fontWeight(isPastExpired(item) ? .bold : .regular)
        }
        .foregroundStyle(dateColor(for: item))
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

  private func deleteItem(_ item: FoodItem) {
    do {
      try database.deleteItem(item)
    } catch {
      print("Failed to delete item: \(error)")
    }
  }

  private func toggleFlagged(item: FoodItem) {
    guard let id = item.id else { return }
    do {
      try database.toggleFlagged(id: id)
    } catch {
      print("Failed to toggle flagged: \(error)")
    }
  }

  private func isExpired(_ item: FoodItem) -> Bool {
    isPastExpired(item) || Calendar.current.isDateInToday(item.expirationDate)
  }

  private func isPastExpired(_ item: FoodItem) -> Bool {
    item.expirationDate < Calendar.current.startOfDay(for: Date())
  }

  private func isExpiringSoon(_ item: FoodItem) -> Bool {
    guard !isExpired(item) else { return false }
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    guard let oneWeekFromNow = calendar.date(byAdding: .day, value: 7, to: today) else {
      return false
    }
    return item.expirationDate < oneWeekFromNow
  }

  private func dateColor(for item: FoodItem) -> Color {
    if isExpired(item) {
      return .red
    } else if isExpiringSoon(item) {
      return .yellow
    } else {
      return .secondary
    }
  }
}
