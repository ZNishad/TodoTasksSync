//
//  NotificationManager.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 12.08.26.
//

import NotificationCenter
import Combine

@MainActor
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleNotification(for task: TodoTask) {
        guard let dueDate = task.dueDate, let id = task.id else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder".localized
        content.body = task.title
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .minute, value: -30, to: dueDate) ?? dueDate

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for task: TodoTask) {
        guard let id = task.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
