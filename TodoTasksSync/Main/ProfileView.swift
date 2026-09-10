//
//  ProfileView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 07.08.26.
//

import SwiftUI

struct ProfileView: View {

    @EnvironmentObject private var authManager: AuthManager

    @State private var oldPass: String = ""
    @State private var newPass: String = ""
    @State private var newPassConfirm: String = ""
    @State private var name: String = ""
    @State private var deletePassword: String = ""

    @State private var isSavingName: Bool = false
    @State private var isChangingPass: Bool = false
    @State private var isDeletingAccount: Bool = false

    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        ScrollView {
            header
            nameSection
            if !authManager.isGoogleUser {
                passChangeSection
                changeButton
            }
            deleteButton
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, Asset.AppSpacing.lg)
        .padding(.top, authManager.isGoogleUser ? Asset.AppSpacing.lg : 0)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text("Profile".localized)
                    .font(Asset.AppFont.appTitle1)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)
            }
        }
        .alert("Info".localized, isPresented: $showAlert) {
            Button("OK".localized) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            name = authManager.userName
        }
    }
}

// MARK: - Validation

private extension ProfileView {

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nameValidation: FormValidation {
        FormValidation(name: trimmedName, email: "", password: "", confirmPassword: "")
    }

    var passwordValidation: FormValidation {
        FormValidation(name: "", email: "", password: newPass, confirmPassword: newPassConfirm)
    }

    var canSaveName: Bool {
        nameValidation.isNameValid && trimmedName != authManager.userName
    }

    /// The new password is held to the same rules as registration — previously this
    /// screen only checked that the two fields matched.
    var canChangePassword: Bool {
        !oldPass.isEmpty
            && passwordValidation.isPasswordValid
            && passwordValidation.passwordsMatch
    }
}

// MARK: - Sections

private extension ProfileView {

    var header: some View {
        VStack(alignment: .center, spacing: Asset.AppSpacing.md) {
            Text(authManager.currentUserEmail?.prefix(1).uppercased() ?? "?")
                .font(Asset.AppFont.appTitle2)
                .foregroundStyle(Asset.AppColor.appPrimaryText)
                .frame(width: 75, height: 75)
                .background(
                    Asset.AppColor.appPrimaryYellow.opacity(0.5),
                    in: Circle()
                )
                .accessibilityHidden(true)

            VStack(spacing: Asset.AppSpacing.sm) {
                Text(authManager.currentUserEmail ?? "???")
                    .font(Asset.AppFont.appTitle3)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                Text(authManager.isGoogleUser
                     ? "Signed in with Google".localized
                     : "Signed in with Email".localized)
                    .font(Asset.AppFont.appBody)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Asset.AppSpacing.sm)
    }

    var nameSection: some View {
        VStack(alignment: .leading) {
            Text("Name and Surname".localized)
                .font(Asset.AppFont.appHeadline)
                .foregroundStyle(Asset.AppColor.appPrimaryText)
                .padding(.leading, Asset.AppSpacing.sm)

            HStack(spacing: Asset.AppSpacing.sm) {
                AppTextField(placeholder: "Name and Surname".localized,
                             iconName: "person",
                             isError: !nameValidation.isNameValid && !trimmedName.isEmpty,
                             contentType: .name,
                             autocapitalization: .words,
                             fieldText: $name)

                AppButton(title: "Save".localized,
                          style: .primary,
                          isLoading: isSavingName,
                          isDisabled: !canSaveName) {
                    Task { await saveName() }
                }
                .frame(width: 60)
            }
        }
        .padding(.vertical, Asset.AppSpacing.sm)
    }

    var passChangeSection: some View {
        VStack(alignment: .leading, spacing: Asset.AppSpacing.md) {
            Text("Change Password".localized)
                .font(Asset.AppFont.appTitle2)
                .foregroundStyle(Asset.AppColor.appPrimaryText)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, Asset.AppSpacing.sm)

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Old Password".localized)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Enter your password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             contentType: .password,
                             fieldText: $oldPass)
            }

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("New password".localized)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "New password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             isError: !passwordValidation.isPasswordValid && !newPass.isEmpty,
                             contentType: .newPassword,
                             fieldText: $newPass)

                Text("At least 8 characters, uppercase, lowercase & number".localized)
                    .font(Asset.AppFont.appCaption1)
                    .foregroundStyle(passwordValidation.isPasswordValid
                                     ? Asset.AppColor.isSuccess
                                     : Asset.AppColor.appSecondaryText)
                    .animation(.easeInOut(duration: 0.25), value: passwordValidation.isPasswordValid)
            }

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Confirm new password".localized)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Confirm new password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             isError: !passwordValidation.passwordsMatch && !newPassConfirm.isEmpty,
                             contentType: .newPassword,
                             fieldText: $newPassConfirm)
            }
        }
        .padding(.top, Asset.AppSpacing.sm)
    }

    var changeButton: some View {
        VStack {
            AppButton(title: "Change Password".localized,
                      style: .primary,
                      isLoading: isChangingPass,
                      isDisabled: !canChangePassword) {
                Task { await changePassword() }
            }
        }
        .padding(.vertical, Asset.AppSpacing.sm)
    }

    var deleteButton: some View {
        VStack(alignment: .center) {
            Button {
                showDeleteConfirmation = true
            } label: {
                if isDeletingAccount {
                    ProgressView()
                } else {
                    Text("Delete Account".localized)
                        .foregroundStyle(Asset.AppColor.isError)
                }
            }
            .disabled(isDeletingAccount)
            .alert("Delete your account?".localized, isPresented: $showDeleteConfirmation) {
                // Firebase refuses to delete an account without a recent login, so an
                // email user has to confirm with their password here.
                if !authManager.isGoogleUser {
                    SecureField("Enter your password".localized, text: $deletePassword)
                }

                Button("Cancel".localized, role: .cancel) {
                    deletePassword = ""
                }

                Button("Delete".localized, role: .destructive) {
                    Task { await deleteAccount() }
                }
            } message: {
                Text(authManager.isGoogleUser
                     ? "This will permanently delete your account and all your tasks. This action cannot be undone.".localized
                     : "This will permanently delete your account and all your tasks. This action cannot be undone. Enter your password to confirm.".localized)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, Asset.AppSpacing.lg)
    }
}

// MARK: - Actions

private extension ProfileView {

    func saveName() async {
        isSavingName = true
        defer { isSavingName = false }

        let success = await authManager.updateUserName(trimmedName)

        alertMessage = success
            ? "Name updated successfully".localized
            : (authManager.errorMessage ?? "Something went wrong".localized)
        showAlert = true
    }

    func changePassword() async {
        isChangingPass = true
        defer { isChangingPass = false }

        let success = await authManager.changePassword(currentPassword: oldPass, newPassword: newPass)

        if success {
            oldPass = ""
            newPass = ""
            newPassConfirm = ""
        }

        alertMessage = success
            ? "Password updated successfully".localized
            : (authManager.errorMessage ?? "Something went wrong".localized)
        showAlert = true
    }

    func deleteAccount() async {
        isDeletingAccount = true

        let success = await authManager.deleteAccount(
            password: authManager.isGoogleUser ? nil : deletePassword
        )

        deletePassword = ""
        isDeletingAccount = false

        // On success the auth state listener tears this whole flow down,
        // so only failure needs reporting here — previously it was silent.
        guard !success else { return }

        alertMessage = authManager.errorMessage ?? "Something went wrong".localized
        showAlert = true
    }
}
