// Copyright Justin Bishop, 2026

import SwiftUI

@main
struct pantrydatesApp: App {
    @Environment(\.scenePhase) private var scenePhase

    let database: AppDatabase

    init() {
        do {
            database = try AppDatabase.makeDefault()
        } catch {
            fatalError("Failed to initialize database: \(error)")
        }

        NotificationManager.registerBackgroundTask()
        NotificationManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(database: database)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                NotificationManager.scheduleBackgroundTask()
            }
        }
    }
}
