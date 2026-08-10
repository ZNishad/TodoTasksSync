//
//  MainRouterView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import SwiftUI

struct TaskRouterView: View {

    @StateObject private var taskManager = TaskManager()
    @StateObject private var taskRouter = TaskRouter()

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
        .onAppear {
            taskManager.startListening()
        }
        .onDisappear {
            taskManager.stopListening()
        }
    }
}
