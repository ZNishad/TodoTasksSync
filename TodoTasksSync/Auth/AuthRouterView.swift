//
//  ContentView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 27.07.26.
//

import SwiftUI

struct AuthRouterView: View {

    @StateObject private var authRouter = AuthRouter()

    var body: some View {
        NavigationStack(path: $authRouter.path) {
            WelcomeView()
                .navigationDestination(for: AuthDestination.self) { destination in
                    switch destination {
                    case .signIn:
                        SignInView()
                    case .signUp:
                        SignUpView()
                    case .forgotPassword:
                        ForgotPassView()
                    case .privacyPolicy:
                        PrivacyPolicy()
                    }
                }
        }
        .environmentObject(authRouter)
    }
}

#Preview {
    AuthRouterView()
}
