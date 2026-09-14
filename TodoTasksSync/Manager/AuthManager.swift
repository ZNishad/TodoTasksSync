//
//  AuthManager.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 27.07.26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import Combine

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserEmail: String? = nil
    @Published var errorMessage: String? = nil
    @Published var userName: String = ""

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.isAuthenticated = (user != nil && user?.isEmailVerified == true)
                self?.currentUserEmail = user?.email
                self?.userName = user?.displayName ?? ""
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

            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        errorMessage = nil

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)

            try await result.user.reload()

            guard let user = Auth.auth().currentUser else {
                errorMessage = "User is not authenticated".localized
                return
            }

            if !user.isEmailVerified {
                errorMessage = "Your account is not verified. Please check your email.".localized
                try Auth.auth().signOut()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
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
            errorMessage = "Unable to find root view controller".localized
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Failed to get ID token".localized
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            _ = try await Auth.auth().signIn(with: credential)
        } catch {
            let nsError = error as NSError
            guard !(nsError.domain == kGIDSignInErrorDomain
                    && nsError.code == Self.googleSignInCanceledCode) else { return }

            errorMessage = error.localizedDescription
        }
    }

    private static let googleSignInCanceledCode = -5

    func updateUserName(_ name: String) async -> Bool {
        errorMessage = nil

        guard let user = Auth.auth().currentUser else {
            errorMessage = "User is not authenticated".localized
            return false
        }

        do {
            let newName = name.trimmingCharacters(in: .whitespacesAndNewlines)

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = newName

            try await changeRequest.commitChanges()

            userName = newName

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    var isGoogleUser: Bool {
        Auth.auth().currentUser?.providerData.contains {
            $0.providerID == "google.com"
        } ?? false
    }

    var firstName: String {
        userName.split(separator: " ").first.map(String.init) ?? ""
    }

    func changePassword(currentPassword: String, newPassword: String) async -> Bool {
        errorMessage = nil

        guard let user = Auth.auth().currentUser, let email = user.email else {
            errorMessage = "User is not authenticated".localized
            return false
        }

        do {
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword
            )

            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteAccount(password: String? = nil) async -> Bool {
        errorMessage = nil

        guard let user = Auth.auth().currentUser else {
            errorMessage = "User is not authenticated".localized
            return false
        }

        do {
            if isGoogleUser {
                guard let googleUser = try? await refreshedGoogleUser(),
                      let idToken = googleUser.idToken?.tokenString else {
                    errorMessage = "Unable to reauthenticate with Google".localized
                    return false
                }
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: googleUser.accessToken.tokenString
                )
                try await user.reauthenticate(with: credential)
            } else if let email = user.email, let password, !password.isEmpty {
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                try await user.reauthenticate(with: credential)
            } else {
                errorMessage = "Please enter your password to delete your account.".localized
                return false
            }

            try await deleteAllTasks(for: user.uid)

            try await user.delete()

            do {
                try await GIDSignIn.sharedInstance.disconnect()
            } catch {
                GIDSignIn.sharedInstance.signOut()
            }

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func refreshedGoogleUser() async throws -> GIDGoogleUser {
        let signIn = GIDSignIn.sharedInstance

        if let currentUser = signIn.currentUser {
            return try await currentUser.refreshTokensIfNeeded()
        }

        return try await signIn.restorePreviousSignIn()
    }

    private func deleteAllTasks(for userId: String) async throws {
        let db = Firestore.firestore()

        let snapshot = try await db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        guard !snapshot.documents.isEmpty else { return }

        for chunk in snapshot.documents.chunked(into: 400) {
            let batch = db.batch()
            chunk.forEach { batch.deleteDocument($0.reference) }
            try await batch.commit()
        }
    }
}
