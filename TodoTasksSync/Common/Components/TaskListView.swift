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
    let onTap: (TodoTask) -> Void
    var onMoveToToday: ((TodoTask) -> Void)? = nil

    var body: some View {
        List {
            ForEach(sections, id: \.title) { section in
                if !section.tasks.isEmpty {
                    Section(section.title) {
                        ForEach(section.tasks) { task in
                            row(for: task)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func row(for task: TodoTask) -> some View {
        TaskCard(task: task)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap(task)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    onDelete(task)
                } label: {
                    Label("Delete".localized, systemImage: "trash")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    onComplete(task)
                } label: {
                    if task.isCompleted {
                        Label("Undo".localized, systemImage: "arrow.uturn.backward")
                    } else {
                        Label("Done".localized, systemImage: "checkmark")
                    }
                }
                .tint(task.isCompleted ? Asset.AppColor.appPrimaryYellow : Asset.AppColor.isSuccess)

                if task.isOverdue, let onMoveToToday {
                    Button {
                        onMoveToToday(task)
                    } label: {
                        Label("Today".localized, systemImage: "arrow.forward.circle")
                    }
                    .tint(Asset.AppColor.appPrimaryYellow)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}
