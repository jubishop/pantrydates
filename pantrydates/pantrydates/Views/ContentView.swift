// Copyright Justin Bishop, 2026

import SwiftUI

struct ContentView: View {
  let database: AppDatabase

  var body: some View {
    TabView {
      Tab("Current", systemImage: "fork.knife") {
        CurrentItemsView(database: database)
      }
      Tab("Finished", systemImage: "checkmark.circle") {
        FinishedItemsView(database: database)
      }
    }
  }
}
