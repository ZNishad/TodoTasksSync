//
//  AuthManager.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 27.07.26.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Combine

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserEmail: String? = nil
    @Published var errorMessage: String? = nil

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.isAuthenticated = (user != nil && user?.isEmailVerified == true)
                self?.currentUserEmail = user?.email
            }
        })
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await result.user.sendEmailVerification()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            if !result.user.isEmailVerified {
                errorMessage = "Your account is not verified. Please check your email.".localized
                try? Auth.auth().signOut()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendPasswordReset(email: String) async -> Bool {
        errorMessage = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func signInWithGoogle() async {
        errorMessage = nil

        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else {
            errorMessage = "Unable to find root view controller"
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Failed to get ID token"
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            _ = try await Auth.auth().signIn(with: credential)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
