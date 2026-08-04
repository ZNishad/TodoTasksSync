//
//  MainRouterView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import SwiftUI

struct MainRouterView: View {

    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        VStack {
            Button {
                Task {
                    authManager.signOut()
                }
            } label: {
                Text("Log out")
            }
        }
    }
}
