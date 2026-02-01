// Copyright Justin Bishop, 2026

import SwiftUI

@main
struct pantrydatesApp: App {
    let database: AppDatabase

    init() {
        do {
            database = try AppDatabase.makeDefault()
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(database: database)
        }
    }
}
