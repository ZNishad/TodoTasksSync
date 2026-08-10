//
//  HistoryView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 04.08.26.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var taskManager: TaskManager

    var body: some View {
        header
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("History".localized)
                        .font(Asset.AppFont.appTitle1)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Asset.AppImage.clock
                        .foregroundStyle(Asset.AppColor.appPrimraryYellow)
                }

            }
    }
}

extension HistoryView {
    private var header: some View {
        List {
            ForEach(historyTasks.keys.sorted(by: >), id: \.self) { date in
                Section {
                    ForEach(historyTasks[date] ?? []) { task in
                        HStack {
                            Text(task.title)

                            Spacer()

                            Text(task.completedAt?.formatted(.dateTime.hour().minute()) ?? "")
                        }

                    }
                } header: {
                    Text(date.formatted(.dateTime.month(.wide).day()))
                }
            }
        }
    }
}

private extension HistoryView {
    private var historyTasks: [Date: [TodoTask]] {
        Dictionary(grouping: taskManager.tasks.filter { task in
            guard let dueDate = task.dueDate,
                  task.isCompleted else {
                return false
            }

            return dueDate < Calendar.current.startOfDay(for: Date())
        }) { task in
            Calendar.current.startOfDay(
                for: task.dueDate!
            )
        }
    }
}
