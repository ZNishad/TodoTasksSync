//
//  AuthRouter.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import SwiftUI
import Combine

enum AuthDestination: Hashable {
    case signIn, signUp
}

@MainActor
final class AuthRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ destination: AuthDestination) {
        path.append(destination)
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func popToRootAndPush(_ destination: AuthDestination) {
        path = NavigationPath([destination])
    }

}
