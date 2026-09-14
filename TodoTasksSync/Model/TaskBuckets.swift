//
//  TaskBuckets.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 14.09.26.
//

import Foundation

struct TaskBuckets {
    private(set) var overdue: [TodoTask] = []
    private(set) var todayActive: [TodoTask] = []
    private(set) var todayCompleted: [TodoTask] = []
    private(set) var upcomingActive: [TodoTask] = []
    private(set) var upcomingCompleted: [TodoTask] = []

    init(tasks: [TodoTask], now: Date = Date(), calendar: Calendar = .current) {
        for task in tasks {
            guard let dueDate = task.dueDate else { continue }

            let isToday = calendar.isDate(dueDate, inSameDayAs: now)

            if task.isCompleted {
                if isToday {
                    todayCompleted.append(task)
                } else if dueDate > now {
                    upcomingCompleted.append(task)
                }
            } else if dueDate < now {
                overdue.append(task)
            } else if isToday {
                todayActive.append(task)
            } else {
                upcomingActive.append(task)
            }
        }

        overdue.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        todayActive.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        upcomingActive.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }

        todayCompleted.sort { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
        upcomingCompleted.sort { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }
}
