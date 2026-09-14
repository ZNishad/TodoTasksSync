//
//  TaskManager.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 04.08.26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class TaskManager: ObservableObject {
    @Published var tasks: [TodoTask] = []
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let notificationManager: NotificationManager

    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }

    func startListening() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        stopListening()

        listener = db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor [weak self] in
                    guard let self else { return }

                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    guard let documents = snapshot?.documents else { return }

                    self.tasks = documents.compactMap { doc in
                        try? doc.data(as: TodoTask.self)
                    }
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    deinit {
        listener?.remove()
    }

    private func sanitizedTitle(_ title: String) -> String? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return nil }

        guard trimmed.count <= TodoTask.titleLimit else {
            errorMessage = "Title is too long".localized
            return nil
        }

        return trimmed
    }

    func addTask(title: String, dueDate: Date?) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let trimmedTitle = sanitizedTitle(title) else { return }

        let docRef = db.collection("tasks").document()

        let newTask = TodoTask(
            id: docRef.documentID,
            title: trimmedTitle,
            isCompleted: false,
            createdAt: Date(),
            dueDate: dueDate ?? Date().endOfDay,
            completedAt: nil,
            userId: userId
        )

        do {
            try docRef.setData(from: newTask)
            notificationManager.scheduleNotification(for: newTask)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompletion(for task: TodoTask) {
        guard let id = task.id else { return }

        let isNowCompleted = !task.isCompleted
        let updates: [String: Any] = [
            "isCompleted": isNowCompleted,
            "completedAt": isNowCompleted ? Date() : NSNull()
        ]

        db.collection("tasks").document(id).updateData(updates) { [weak self] error in
            Task { @MainActor [weak self] in
                if let error {
                    self?.errorMessage = error.localizedDescription
                } else if isNowCompleted {
                    self?.notificationManager.cancelNotification(for: task)
                } else {
                    var reopened = task
                    reopened.isCompleted = false
                    reopened.completedAt = nil
                    self?.notificationManager.scheduleNotification(for: reopened)
                }
            }
        }
    }

    func deleteTask(_ task: TodoTask) {
        guard let id = task.id else { return }

        db.collection("tasks").document(id).delete { [weak self] error in
            Task { @MainActor [weak self] in
                if let error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.notificationManager.cancelNotification(for: task)
                }
            }
        }
    }

    func updateTask(_ task: TodoTask, title: String, dueDate: Date) {
        guard let id = task.id else { return }
        guard let trimmedTitle = sanitizedTitle(title) else { return }

        db.collection("tasks").document(id).updateData([
            "title": trimmedTitle,
            "dueDate": Timestamp(date: dueDate)
        ]) { [weak self] error in
            Task { @MainActor [weak self] in
                guard let self else { return }

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                var updated = task
                updated.title = trimmedTitle
                updated.dueDate = dueDate
                self.notificationManager.scheduleNotification(for: updated)
            }
        }
    }

    func reschedule(_ task: TodoTask, to dueDate: Date) {
        guard let id = task.id else { return }

        db.collection("tasks").document(id).updateData([
            "dueDate": Timestamp(date: dueDate)
        ]) { [weak self] error in
            Task { @MainActor [weak self] in
                guard let self else { return }

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                var updated = task
                updated.dueDate = dueDate
                self.notificationManager.scheduleNotification(for: updated)
            }
        }
    }

    func moveToToday(_ task: TodoTask) {
        reschedule(task, to: Date().endOfDay)
    }
}
