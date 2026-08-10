//
//  MainView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 04.08.26.
//

import SwiftUI

struct MainView: View {

    @EnvironmentObject private var taskRouter: TaskRouter
    @EnvironmentObject private var taskManager: TaskManager
    @EnvironmentObject private var authManager: AuthManager

    @State private var selectedSegment: Segment = .today
    @Namespace private var segmentAnimation

    @State private var pendingConfirmation: ConfirmationAction?

    @State private var showAddTask = false
    @State private var showProfile = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: Asset.AppSpacing.sm) {
                headerSegment

                switch selectedSegment {
                case .today:
                    todayView
                case .upcoming:
                    upcomingView
                }
            }

            plus
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Tasks")
                    .font(Asset.AppFont.appTitle1)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {

                    Button {
                        showProfile.toggle()
                    } label: {
                        Label(authManager.userName == "" ? "Profile".localized : authManager.firstName, systemImage: "person")
                    }

                    Button {
                        taskRouter.push(.history)
                    } label: {
                        Label("History".localized, systemImage: "clock.arrow.circlepath")
                    }

                    Divider()

                    Button(role: .destructive) {
                        authManager.signOut()
                    } label: {
                        Label("Logout".localized, systemImage: "rectangle.portrait.and.arrow.right")
                    }

                } label: {
                    Asset.AppImage.option
                        .foregroundStyle(Asset.AppColor.appPrimraryYellow)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddTask) {
            AddTaskView()
                .presentationDetents([.fraction(0.5)])
                .presentationBackground(Asset.AppColor.appBackground)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .presentationDetents([authManager.isGoogleUser ? .fraction(0.45) : .large])
                .presentationBackground(Asset.AppColor.appBackground)
                .presentationDragIndicator(.visible)
        }

    }
}

extension MainView {

    private enum Segment: String, CaseIterable {
        case today = "Today"
        case upcoming = "Upcoming"

        var title: String {
            rawValue.localized
        }
    }

    @ViewBuilder
    private var headerSegment: some View {
        HStack(spacing: 4) {
            ForEach(Segment.allCases, id: \.self) { segment in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedSegment = segment
                    }
                } label: {
                    ZStack {
                        if selectedSegment == segment {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Asset.AppColor.appBackground)
                                .matchedGeometryEffect(id: "indicator", in: segmentAnimation)
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                        }

                        Text(segment.title)
                            .font(Asset.AppFont.appHeadline)
                            .fontWeight(selectedSegment == segment ? .semibold : .medium)
                            .foregroundStyle(
                                selectedSegment == segment
                                ? Asset.AppColor.appPrimaryText
                                : Asset.AppColor.appSecondaryText
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Asset.AppSpacing.sm / 2)
        .background(
            RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
                .fill(Asset.AppColor.appSeparator)
        )
        .padding(.horizontal, Asset.AppSpacing.md)
    }

    @ViewBuilder
    private var todayView: some View {
        TaskListView(
            sections: [
                ("Overdue".localized, overdueTasks),
                ("Active".localized, todayActiveTasks),
                ("Completed".localized, todayCompletedTasks)
            ],
            onComplete: { task in
                if task.isCompleted {
                    pendingConfirmation = .makeActive(task)
                } else {
                    pendingConfirmation = .completeTask(task)
                }
            },
            onDelete: { task in
                pendingConfirmation = .deleteTask(task)
            }
        )
    }

    @ViewBuilder
    private var upcomingView: some View {
        TaskListView(
            sections: [
                ("Active".localized, upcomingActiveTasks),
                ("Completed".localized, upcomingCompletedTasks)
            ],
            onComplete: { task in
                if task.isCompleted {
                    pendingConfirmation = .makeActive(task)
                } else {
                    pendingConfirmation = .completeTask(task)
                }
            },
            onDelete: { task in
                pendingConfirmation = .deleteTask(task)
            }
        )
    }

    @ViewBuilder
    private var plus: some View {
        Button {
            showAddTask = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Asset.AppColor.appPrimaryText)
                .frame(width: 56, height: 56)
                .background(Asset.AppColor.appPrimraryYellow)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding(Asset.AppSpacing.lg)
    }
}


// MARK: - Filter && Sort

private extension MainView {

    // MARK: - Today

    private var todayActiveTasks: [TodoTask] {
        taskManager.tasks
            .filter { task in
                guard let dueDate = task.dueDate, !task.isCompleted else { return false }
                return Calendar.current.isDateInToday(dueDate) && !task.isOverdue
            }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private var overdueTasks: [TodoTask] {
        taskManager.tasks.filter { $0.isOverdue }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private var todayCompletedTasks: [TodoTask] {
        taskManager.tasks.filter { task in
            guard let dueDate = task.dueDate, task.isCompleted else { return false }
            return Calendar.current.isDateInToday(dueDate)
        }
        .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    // MARK: - Upcoming

    private var upcomingActiveTasks: [TodoTask] {
        taskManager.tasks.filter { task in
            guard let dueDate = task.dueDate, !task.isCompleted else { return false }
            return dueDate > Date() && !Calendar.current.isDateInToday(dueDate)
        }
        .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private var upcomingCompletedTasks: [TodoTask] {
        taskManager.tasks.filter { task in
            guard let dueDate = task.dueDate, task.isCompleted else { return false }
            return dueDate > Date() && !Calendar.current.isDateInToday(dueDate)
        }
        .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

}

