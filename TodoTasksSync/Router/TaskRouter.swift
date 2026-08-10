//
//  MainRouter.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 04.08.26.
//

import SwiftUI
import Combine

enum TaskDestination: Hashable {
    case history, profile
}

@MainActor
final class TaskRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ destination: TaskDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

}
