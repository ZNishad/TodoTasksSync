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

    @State private var showAddTask = false
    @State private var showProfile = false
    @State private var showLogoutConfirmation = false
    @State private var selectedTask: TodoTask?

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
                Text("Tasks".localized)
                    .font(Asset.AppFont.appTitle1)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {

                    Button {
                        if authManager.isGoogleUser {
                            showProfile.toggle()
                        } else {
                            taskRouter.push(.profile)
                        }

                    } label: {
                        Label(authManager.userName.isEmpty ? "Profile".localized : authManager.firstName, systemImage: "person")
                    }

                    Button {
                        taskRouter.push(.history)
                    } label: {
                        Label("History".localized, systemImage: "clock.arrow.circlepath")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showLogoutConfirmation.toggle()
                    } label: {
                        Label("Logout".localized, systemImage: "rectangle.portrait.and.arrow.right")
                    }

                } label: {
                    Asset.AppImage.option
                        .foregroundStyle(Asset.AppColor.appPrimaryYellow)
                }
                .accessibilityLabel("More options".localized)
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
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
                .presentationDetents([.fraction(0.75), .large])
                .presentationBackground(Asset.AppColor.appBackground)
                .presentationDragIndicator(.visible)
        }
        // Key wording is deliberately distinct from the "Logout" menu item: the
        // string catalog derives a Swift symbol per key and near-identical keys collide.
        .alert("Log out of your account?".localized, isPresented: $showLogoutConfirmation) {
            Button("Cancel".localized, role: .cancel) { }
            Button("Yes, log out".localized, role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to log out?".localized)
        }
        // Firestore write failures were previously only stored on the manager
        // and never reached the user.
        .alert("Error".localized, isPresented: taskErrorBinding) {
            Button("OK".localized) { taskManager.errorMessage = nil }
        } message: {
            Text(taskManager.errorMessage ?? "")
        }
    }

    private var taskErrorBinding: Binding<Bool> {
        Binding(
            get: { taskManager.errorMessage != nil },
            set: { isPresented in
                if !isPresented { taskManager.errorMessage = nil }
            }
        )
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
        taskList(for: todaySections, allowMoveToToday: true)
    }

    @ViewBuilder
    private var upcomingView: some View {
        taskList(for: upcomingSections, allowMoveToToday: false)
    }

    /// One place that wires a set of sections to the manager, so the empty-state
    /// check reuses the sections that were already computed instead of re-filtering.
    @ViewBuilder
    private func taskList(
        for sections: [(title: String, tasks: [TodoTask])],
        allowMoveToToday: Bool
    ) -> some View {
        TaskListView(
            sections: sections,
            onComplete: { taskManager.toggleCompletion(for: $0) },
            onDelete: { taskManager.deleteTask($0) },
            onTap: { selectedTask = $0 },
            onMoveToToday: allowMoveToToday ? { taskManager.moveToToday($0) } : nil
        )
        .overlay {
            if sections.allSatisfy(\.tasks.isEmpty) {
                Asset.AppImage.noTask
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 250)
                    .offset(y: -75)
                    .accessibilityLabel("No tasks yet".localized)
            }
        }
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
                .background(Asset.AppColor.appPrimaryYellow)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding(Asset.AppSpacing.lg)
        .accessibilityLabel("Add Task".localized)
    }
}


// MARK: - Filter && Sort

private extension MainView {

    var todaySections: [(title: String, tasks: [TodoTask])] {
        let buckets = TaskBuckets(tasks: taskManager.tasks)
        return [
            ("Overdue".localized, buckets.overdue),
            ("Active".localized, buckets.todayActive),
            ("Completed".localized, buckets.todayCompleted)
        ]
    }

    var upcomingSections: [(title: String, tasks: [TodoTask])] {
        let buckets = TaskBuckets(tasks: taskManager.tasks)
        return [
            ("Active".localized, buckets.upcomingActive),
            ("Completed".localized, buckets.upcomingCompleted)
        ]
    }
}

/// Partitions the task list into the buckets the two segments display.
/// A single pass, so switching segments or redrawing does not re-filter the
/// whole array once per section plus once more for the empty-state check.
/// Stays main-actor isolated along with `TodoTask`, which it reads.
struct TaskBuckets {
    private(set) var overdue: [TodoTask] = []
    private(set) var todayActive: [TodoTask] = []
    private(set) var todayCompleted: [TodoTask] = []
    private(set) var upcomingActive: [TodoTask] = []
    private(set) var upcomingCompleted: [TodoTask] = []

    init(tasks: [TodoTask], now: Date = Date(), calendar: Calendar = .current) {
        for task in tasks {
            guard let dueDate = task.dueDate else { continue }

            // Compared against the injected `now`, not `isDateInToday`, so the
            // whole partition has a single source of truth for "today".
            let isToday = calendar.isDate(dueDate, inSameDayAs: now)

            if task.isCompleted {
                // Keyed off the completion date, not the due date. Keying off the due
                // date made a task finished today but due earlier fall through every
                // bucket — History only covers previous days — and vanish from the UI.
                let completionDay = task.completedAt ?? dueDate

                if calendar.isDate(completionDay, inSameDayAs: now) {
                    todayCompleted.append(task)
                } else if dueDate > now {
                    upcomingCompleted.append(task)
                }
                // Completed on an earlier day and no longer upcoming — that is History.
            } else if dueDate < now {
                overdue.append(task)
            } else if isToday {
                todayActive.append(task)
            } else {
                upcomingActive.append(task)
            }
        }

        // Written inline rather than hoisted into named comparators. `sort(by:)`
        // invokes its predicate in a nonisolated context, and a `static func` would
        // carry this target's `MainActor` default isolation, which cannot cross into
        // it. A closure literal infers the caller's isolation, so it can.
        //
        // Soonest due first.
        overdue.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        todayActive.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        upcomingActive.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }

        // Most recently completed first.
        todayCompleted.sort { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
        upcomingCompleted.sort { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }
}

