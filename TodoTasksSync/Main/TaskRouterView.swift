//
//  MainRouterView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import SwiftUI

struct TaskRouterView: View {

    @StateObject private var taskManager: TaskManager
    @StateObject private var taskRouter = TaskRouter()
    @StateObject private var notificationManager: NotificationManager

    init() {
        let notificationManager = NotificationManager()
        _notificationManager = StateObject(wrappedValue: notificationManager)
        _taskManager = StateObject(wrappedValue: TaskManager(notificationManager: notificationManager))
    }

    var body: some View {
        NavigationStack(path: $taskRouter.path) {
            MainView()
                .navigationDestination(for: TaskDestination.self) { destination in
                    switch destination {
                    case .history:
                        HistoryView()
                    case .profile:
                        ProfileView()
                    }
                }
        }
        .environmentObject(taskManager)
        .environmentObject(taskRouter)
        .environmentObject(notificationManager)
        .onAppear {
            taskManager.startListening()
            Task {
                _ = await notificationManager.requestNotificationPermission()
            }

        }
        .onDisappear {
            taskManager.stopListening()
        }
    }
}
