// Copyright Justin Bishop, 2026

import BackgroundTasks
import Foundation
import UserNotifications

struct NotificationManager {
  static let backgroundTaskIdentifier = "com.pantrydates.notificationCheck"

  static func requestAuthorization() {
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
          print("Notification authorization error: \(error)")
        }
      }
  }

  static func registerBackgroundTask() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) {
      task in
      handleBackgroundTask(task as! BGAppRefreshTask)
    }
  }

  static func scheduleBackgroundTask() {
    let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60 * 60)  // 2 hours

    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Failed to schedule background task: \(error)")
    }
  }

  private static func handleBackgroundTask(_ task: BGAppRefreshTask) {
    scheduleBackgroundTask()  // Schedule the next one

    let taskOperation = Task {
      do {
        let database = try AppDatabase.makeDefault()
        try await processNotifications(database: database)
        task.setTaskCompleted(success: true)
      } catch {
        print("Background task failed: \(error)")
        task.setTaskCompleted(success: false)
      }
    }

    task.expirationHandler = {
      taskOperation.cancel()
    }
  }

  static func processNotifications(database: AppDatabase) async throws {
    let items = try database.fetchItemsPendingNotification()

    for item in items {
      guard let id = item.id else { continue }

      let content = UNMutableNotificationContent()
      content.title = "Pantry Reminder"
      content.body = "\(item.name) needs your attention"
      content.sound = .default

      let request = UNNotificationRequest(
        identifier: "pantry-\(id)",
        content: content,
        trigger: nil  // Deliver immediately
      )

      try await UNUserNotificationCenter.current().add(request)
      try database.markNotificationSent(id: id)
    }
  }
}
