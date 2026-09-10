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

    /// Minutes before the due date at which the reminder fires.
    private static let reminderLeadTime = 30

    func scheduleNotification(for task: TodoTask) {
        guard let id = task.id else { return }

        let center = UNUserNotificationCenter.current()

        // Always clear the previous request: the due date may have moved, and a
        // stale reminder for the old date would otherwise still be pending.
        center.removePendingNotificationRequests(withIdentifiers: [id])

        guard let dueDate = task.dueDate, !task.isCompleted else { return }

        let now = Date()
        // Nothing left to remind about once the due date itself has passed.
        guard dueDate > now else { return }

        let leadTimeDate = Calendar.current.date(
            byAdding: .minute,
            value: -Self.reminderLeadTime,
            to: dueDate
        ) ?? dueDate

        // For a task due in less than the lead time, fall back to the due date itself
        // rather than scheduling into the past, where the trigger would never fire.
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
