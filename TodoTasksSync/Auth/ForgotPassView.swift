//
//  ForgotPassView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 02.08.26.
//

import SwiftUI

struct ForgotPassView: View {
    @State private var emailFieldText: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var resetSucceeded: Bool = false
    @State private var isResetPass: Bool = false

    @EnvironmentObject private var authManager: AuthManager

    @Environment(\.dismiss) private var dismiss

    var emailValid: Bool {
        EmailValidator.isValid(emailFieldText)
    }

    var body: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            header
            mainSection
            footer
            Spacer()
        }
        .padding(.top, Asset.AppSpacing.lg)
        .alert("Info".localized, isPresented: $showAlert) {
            Button("OK".localized) {
                if resetSucceeded { dismiss() }
            }
        } message: {
            Text(alertMessage)
        }
    }
}

extension ForgotPassView {

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .center, spacing: Asset.AppSpacing.sm) {
            Asset.AppImage.forgotPassHeader
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, Asset.AppSpacing.md)

            VStack(spacing: Asset.AppSpacing.sm) {
                Text("Forgot password?".localized)
                    .font(Asset.AppFont.appTitle1)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                Text("No worries. Enter your email and we'll send you a link to reset it.".localized)
                    .font(Asset.AppFont.appBody)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Asset.AppSpacing.lg)
    }

    @ViewBuilder
    private var mainSection: some View {
        VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
            Text("Email".localized)
                .font(Asset.AppFont.appHeadline)
                .foregroundStyle(Asset.AppColor.appPrimaryText)

            AppTextField(placeholder: "Enter your email".localized,
                         iconName: "envelope.fill",
                         isError: !emailValid && !emailFieldText.isEmpty,
                         contentType: .emailAddress,
                         fieldText: $emailFieldText)
                .keyboardType(.emailAddress)
        }
        .padding(.horizontal, Asset.AppSpacing.lg)
    }

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            AppButton(title: "Send Reset Link", style: .primary, isLoading: isResetPass, isDisabled: !emailValid) {
                Task {
                    isResetPass = true
                    defer { isResetPass = false }

                    let success = await authManager.sendPasswordReset(email: emailFieldText)
                    resetSucceeded = success
                    alertMessage = success
                        ? "Password reset link sent to your email".localized
                        : (authManager.errorMessage ?? "Something went wrong".localized)
                    showAlert = true
                }
            }

            HStack{
                Text("Remembered it?".localized)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)

                Button {
                    dismiss()
                } label: {
                    Text("Sign In".localized)
                        .font(Asset.AppFont.appHeadline)
                        .foregroundStyle(Asset.AppColor.appPrimaryYellow)

                }
            }
        }
        .padding(.horizontal, Asset.AppSpacing.lg)
    }

}
