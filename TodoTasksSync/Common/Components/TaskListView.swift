//
//  TaskListView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 07.08.26.
//

import SwiftUI

struct TaskListView: View {
    let sections: [(title: String, tasks: [TodoTask])]
    let onComplete: (TodoTask) -> Void
    let onDelete: (TodoTask) -> Void

    @EnvironmentObject private var taskManager: TaskManager

    var body: some View {
        List {
            ForEach(sections, id: \.title) { section in
                if !section.tasks.isEmpty {
                    Section(section.title) {
                        ForEach(section.tasks) { task in
                            TaskCard(task: task)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        taskManager.deleteTask(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        taskManager.toggleCompletion(for: task)
                                    } label: {
                                        if task.isCompleted {
                                            Label("Undo", systemImage: "arrow.uturn.backward")
                                        } else {
                                            Label("Done", systemImage: "checkmark")
                                        }
                                    }
                                    .tint(task.isCompleted ? Asset.AppColor.appPrimraryYellow : Asset.AppColor.isSuccess)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
