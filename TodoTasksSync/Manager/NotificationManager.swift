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

    private static let reminderLeadTime = 30

    func scheduleNotification(for task: TodoTask) {
        guard let id = task.id else { return }

        let center = UNUserNotificationCenter.current()

        center.removePendingNotificationRequests(withIdentifiers: [id])

        guard let dueDate = task.dueDate, !task.isCompleted else { return }

        let now = Date()
        guard dueDate > now else { return }

        let leadTimeDate = Calendar.current.date(
            byAdding: .minute,
            value: -Self.reminderLeadTime,
            to: dueDate
        ) ?? dueDate

        let triggerDate = leadTimeDate > now ? leadTimeDate : dueDate

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder".localized
        content.body = task.title
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        center.add(request)
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
