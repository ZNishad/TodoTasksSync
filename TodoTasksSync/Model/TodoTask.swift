//
//  TodoTask.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 04.08.26.
//

import SwiftUI
import FirebaseFirestore

struct TodoTask: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    var dueDate: Date?
    var completedAt: Date?
    var userId: String

    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }


}
