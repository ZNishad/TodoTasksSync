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
        list
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("History".localized)
                        .font(Asset.AppFont.appTitle1)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Asset.AppImage.clock
                        .foregroundStyle(Asset.AppColor.appPrimaryYellow)
                        .accessibilityHidden(true)
                }
            }
    }
}

private extension HistoryView {

    var list: some View {
        List {
            ForEach(historyDays, id: \.date) { day in
                Section {
                    ForEach(day.tasks) { task in
                        HStack {
                            Text(task.title)

                            Spacer()

                            Text(task.completedAt?.formatted(.dateTime.hour().minute()) ?? "")
                                .foregroundStyle(Asset.AppColor.appSecondaryText)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                taskManager.deleteTask(task)
                            } label: {
                                Label("Delete".localized, systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text(day.date.formatted(.dateTime.month(.wide).day()))
                }
            }
        }
        .overlay {
            if historyDays.isEmpty {
                Asset.AppImage.noHistory
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 250)
                    .offset(y: -75)
                    .accessibilityLabel("No completed tasks yet".localized)
            }
        }
    }

    var historyDays: [(date: Date, tasks: [TodoTask])] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        let completed = taskManager.tasks.compactMap { task -> (day: Date, task: TodoTask)? in
            guard task.isCompleted, let dueDate = task.dueDate else { return nil }

            let day = calendar.startOfDay(for: dueDate)
            guard day < startOfToday else { return nil }

            return (day, task)
        }

        return Dictionary(grouping: completed, by: \.day)
            .map { day, entries in
                (
                    date: day,
                    tasks: entries
                        .map(\.task)
                        .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
                )
            }
            .sorted { $0.date > $1.date }
    }
}
