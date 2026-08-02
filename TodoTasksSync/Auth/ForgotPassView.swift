//
//  ForgotPassView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 02.08.26.
//

import SwiftUI

struct ForgotPassView: View {
    @State private var emailFieldText: String = ""

    @EnvironmentObject private var authRouter: AuthRouter

    @Environment(\.dismiss) private var dismiss

    var emailValid: Bool {
        EmailValidatior.isValid(emailFieldText)
    }

    var body: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            header
            mainSection
            footer
            Spacer()
        }
        .padding(.top, Asset.AppSpacing.lg)
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
                Text("Forgot password?")
                    .font(Asset.AppFont.appTitle1)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                Text("No worries. Enter your email and we'll send you a link to reset it.")
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
            Text("Email")
                .font(Asset.AppFont.appHeadline)
                .foregroundStyle(Asset.AppColor.appPrimaryText)
            
            AppTextField(placeholder: "Enter your email".localized,
                         iconName: "envelope.fill",
                         isError: !emailValid && !emailFieldText.isEmpty,
                         fieldText: $emailFieldText)
        }
        .padding(.horizontal, Asset.AppSpacing.lg)
    }

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            AppButton(title: "Send Resset Link", style: .primary, isDisabled: !emailValid) {

            }

            HStack{
                Text("Remembered it?")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)

                Button {
                    dismiss()
                } label: {
                    Text("Sign In")
                        .font(Asset.AppFont.appHeadline)
                        .foregroundStyle(Asset.AppColor.appPrimraryYellow)

                }
            }
        }
        .padding(.horizontal, Asset.AppSpacing.lg)
    }

}
