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
    @State private var isSavedName = false
    @State private var isChangedPass = false
    @State private var alertMessage = ""
    @State private var resetSucceeded = false
    @State private var showAlert: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: Asset.AppSpacing.lg) {
            header
            nameSection
            if !authManager.isGoogleUser {
                passChangeSection
                changeButton
            }
        }
        .padding(.horizontal, Asset.AppSpacing.lg)
        .toolbar {  
            ToolbarItem(placement: .title) {
                Text("Profile".localized)
                    .font(Asset.AppFont.appTitle1)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)
            }
        }
        .alert("Info", isPresented: $showAlert) {
            Button("OK") {

            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            name = authManager.userName
        }


    }
}

extension ProfileView {
    private var header: some View {
        VStack(alignment: .center, spacing: Asset.AppSpacing.md) {
            Text(authManager.currentUserEmail?.prefix(1).uppercased() ?? "?")
                .font(Asset.AppFont.appTitle2)
                .foregroundStyle(Asset.AppColor.appPrimaryText)
                .frame(width: 75, height: 75)
                .background(
                    Asset.AppColor.appPrimraryYellow.opacity(0.5),
                    in: Circle()
                )

            VStack(spacing: Asset.AppSpacing.sm) {
                Text(authManager.currentUserEmail ?? "???")
                    .font(Asset.AppFont.appTitle3)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                if authManager.isGoogleUser {
                    Text("Signed in with Google")
                        .font(Asset.AppFont.appBody)
                        .foregroundStyle(Asset.AppColor.appSecondaryText)
                } else {
                    Text("Signed in with Email")
                        .font(Asset.AppFont.appBody)
                        .foregroundStyle(Asset.AppColor.appSecondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var nameSection: some View {
        VStack(alignment: .leading) {
            Text("Name and Surname")
                .font(Asset.AppFont.appHeadline)
                .foregroundStyle(Asset.AppColor.appPrimaryText)
                .padding(.leading, Asset.AppSpacing.sm)

            HStack(spacing: Asset.AppSpacing.sm) {
                AppTextField(placeholder: "Name and Surname".localized,
                             iconName: "person",
                             isError: !(name.filter { $0.isLetter }.count >= 2) && !name.isEmpty,
                             fieldText: $name)

                AppButton(title: "Save".localized, style: .primary, isLoading: isSavedName) {
                    Task {
                        isSavedName = true
                        let success = await authManager.updateUserName(name)
                        resetSucceeded = success
                        alertMessage = success
                        ? "Name updated successfully"
                        : (authManager.errorMessage ?? "Something went wrong".localized)
                        isSavedName = false
                        showAlert = true
                    }

                }
                .frame(width: 60)
            }
        }
    }

    private var passChangeSection: some View {
        VStack(alignment: .leading, spacing: Asset.AppSpacing.md) {
            Text("Change Pasword")
                .font(Asset.AppFont.appTitle2)
                .foregroundStyle(Asset.AppColor.appPrimaryText)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom, Asset.AppSpacing.sm)

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Old Password")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Enter your password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             fieldText: $oldPass)
            }

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("New password")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "New password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             fieldText: $newPass)
            }

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Confirm new password")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Confirm new password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             fieldText: $newPassConfirm)
            }
        }
        .padding(.top, Asset.AppSpacing.sm)
    }

    private var changeButton: some View {
        AppButton(title: "Change Password".localized,
                  style: .primary,
                  isLoading: isChangedPass,
                  isDisabled: newPass != newPassConfirm || newPassConfirm.isEmpty
        ) {
            Task {
                isChangedPass = true
                let success = await authManager.changePassword(currentPassword: oldPass, newPassword: newPass)
                resetSucceeded = success
                alertMessage = success
                ? "Password updated successfully".localized
                : (authManager.errorMessage ?? "Something went wrong".localized)
                isChangedPass = false
                showAlert = true
            }
        }
    }
}
