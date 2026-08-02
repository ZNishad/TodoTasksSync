//
//  SignUpView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import SwiftUI

struct SignUpView: View {

    @State private var emailFieldText: String = ""
    @State private var passwordFieldText: String = ""
    @State private var confirmPasswordFieldText: String = ""

    @EnvironmentObject private var authRouter: AuthRouter

    private var validation: FormValidation {
        FormValidation(email: emailFieldText, password: passwordFieldText, confirmPassword: confirmPasswordFieldText)
    }

    var body: some View {
        ScrollView {
            header
            mainSection
            validationSection
            footer
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, Asset.AppSpacing.lg)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    authRouter.popToRoot()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }
            }
        }
        .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
    }
}

extension SignUpView {

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .center, spacing: Asset.AppSpacing.md) {
            Asset.AppImage.signUpHeader
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.bottom, Asset.AppSpacing.lg)

            VStack(spacing: Asset.AppSpacing.sm) {
                Text("Create Account")
                    .font(Asset.AppFont.appTitle1)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                Text("Let's get you started")
                    .font(Asset.AppFont.appBody)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)
            }
        }
    }

    @ViewBuilder
    private var mainSection: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Email")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Enter your email".localized,
                             iconName: "envelope.fill",
                             isError: !validation.isEmailValid,
                             fieldText: $emailFieldText)
            }
            .animation(.spring(duration: 0.7), value: validation.isEmailValid)

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Password")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Enter your password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             fieldText: $passwordFieldText)
            }
            .animation(.spring(duration: 0.7), value: validation.passwordsMatch)

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Confirm password")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Confirm your password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             isError: !validation.passwordsMatch,
                             fieldText: $confirmPasswordFieldText)
            }
            .animation(.spring(duration: 0.7), value: validation.passwordsMatch)
        }
        .padding(.top, Asset.AppSpacing.sm)
    }

    @ViewBuilder
    private var validationSection: some View {
        VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
            HStack(alignment: .top) {
                Asset.AppImage.checkmark
                    .resizable()
                    .scaledToFit()
                    .frame(width: Asset.AppSpacing.sm, height: Asset.AppSpacing.sm)
                    .foregroundStyle(validation.hasMinLength ? Asset.AppColor.isSuccess : Asset.AppColor.appSecondaryText)
                    .padding(.top, Asset.AppSpacing.sm / 2)

                Text("At least 8 characters")
                    .font(Asset.AppFont.appSubheadline)
                    .foregroundStyle(validation.hasMinLength ? Asset.AppColor.isSuccess : Asset.AppColor.appSecondaryText)

                Spacer()
            }
            .animation(.spring(duration: 0.7), value: validation.hasMinLength)

            HStack(alignment: .top) {
                Asset.AppImage.checkmark
                    .resizable()
                    .scaledToFit()
                    .frame(width: Asset.AppSpacing.sm, height: Asset.AppSpacing.sm)
                    .foregroundStyle(validation.isPasswordValid ? Asset.AppColor.isSuccess : Asset.AppColor.appSecondaryText)
                    .padding(.top, Asset.AppSpacing.sm / 2)

                Text("Uppercase, lowercase & number")
                    .font(Asset.AppFont.appSubheadline)
                    .foregroundStyle(validation.isPasswordValid ? Asset.AppColor.isSuccess: Asset.AppColor.appSecondaryText)
            }
            .animation(.spring(duration: 0.7), value: validation.isPasswordValid)

        }
        .padding(.vertical, Asset.AppSpacing.md)

    }


    @ViewBuilder
    private var footer: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            AppButton(title: "Sign Up", style: .primary, isDisabled: !validation.isFormValid) {

            }
            .disabled(!validation.isFormValid)


            HStack{
                Text("Already have an account?")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)

                Button {
                    authRouter.push(.signIn)
                } label: {
                    Text("Sign In")
                        .font(Asset.AppFont.appHeadline)
                        .foregroundStyle(Asset.AppColor.appPrimraryYellow)

                }
            }
        }

    }
}

#Preview {
    SignUpView()
}
