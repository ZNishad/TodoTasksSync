//
//  ConfirmationAction.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 07.08.26.
//

import Foundation
import Combine

enum ConfirmationAction: Identifiable {
    case deleteTask(TodoTask)
    case completeTask(TodoTask)
    case makeActive(TodoTask)
    case logout

    var id: String {
        switch self {
        case .deleteTask(let task): return "delete-\(task.id ?? "")"
        case .completeTask(let task): return "complete-\(task.id ?? "")"
        case .makeActive(let task): return "uncomplete-\(task.id ?? "")"
        case .logout: return "logout"
        }
    }

    var title: String {
        switch self {
        case .deleteTask: return "Delete this task?".localized
        case .completeTask: return "Mark as completed?".localized
        case .makeActive: return "Mark as active?".localized
        case .logout: return "Log Out?".localized
        }
    }

    var message: String {
        switch self {
        case .deleteTask: return "This action cannot be undone.".localized
        case .completeTask: return "".localized
        case .makeActive: return "".localized
        case .logout: return "Are you sure you want to log out?".localized
        }
    }

    var confirmTitle: String {
        switch self {
        case .deleteTask: return "Delete".localized
        case .completeTask: return "Complete".localized
        case .makeActive: return "Active".localized
        case .logout: return "Log Out".localized
        }
    }

    var isDestructive: Bool {
        switch self {
        case .deleteTask, .logout: return true
        case .completeTask, .makeActive: return false
        }
    }
}
