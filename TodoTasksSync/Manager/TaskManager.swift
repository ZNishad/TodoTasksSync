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

    func startListening() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        listener = db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
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

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    deinit {
        listener?.remove()
    }

    func addTask(title: String, dueDate: Date?) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let newTask = TodoTask(
            title: title,
            isCompleted: false,
            createdAt: Date(),
            dueDate: dueDate ?? Date().endOfDay,
            completedAt: nil,
            userId: userId
        )

        do {
            _ = try db.collection("tasks").addDocument(from: newTask)
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
                }
            }
        }
    }

    func moveToToday(_ task: TodoTask) {
        guard let id = task.id else { return }

        db.collection("tasks").document(id).updateData([
            "dueDate": Date()
        ]) { [weak self] error in
            Task { @MainActor [weak self] in
                if let error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
