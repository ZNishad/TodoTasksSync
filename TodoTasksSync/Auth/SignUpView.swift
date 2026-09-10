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
    @State private var showAlert = false
    @State private var isSigningUp = false
    @State private var isPrivacyAccepted: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showPrivacyPolicy = false

    @EnvironmentObject private var authRouter: AuthRouter
    @EnvironmentObject private var authManager: AuthManager

    fileprivate static let privacyPolicyURL = URL(string: "https://znishad.github.io/todotaskssync-privacy/")!

    private var validation: FormValidation {
        FormValidation(name: "", email: emailFieldText, password: passwordFieldText, confirmPassword: confirmPasswordFieldText)
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
        .alert("Check your email".localized, isPresented: $showSuccessAlert) {
            Button("OK".localized) {
                authRouter.push(.signIn)
            }
        } message: {
            Text("We've sent a verification link to your email. Please verify before signing in.".localized)
        }
        .alert("Error".localized, isPresented: $showAlert) {
            Button("OK".localized) { }
        } message: {
            Text(authManager.errorMessage ?? "")
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
                Text("Create Account".localized)
                    .font(Asset.AppFont.appTitle1)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                Text("Let's get you started".localized)
                    .font(Asset.AppFont.appBody)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)
            }
        }
    }

    @ViewBuilder
    private var mainSection: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Email".localized)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Enter your email".localized,
                             iconName: "envelope.fill",
                             isError: !validation.isEmailValid && !emailFieldText.isEmpty,
                             contentType: .emailAddress,
                             fieldText: $emailFieldText)
                    .keyboardType(.emailAddress)
            }

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Password".localized)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Enter your password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             contentType: .newPassword,
                             fieldText: $passwordFieldText)
            }

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Confirm password".localized)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Confirm your password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             isError: !validation.passwordsMatch && !confirmPasswordFieldText.isEmpty,
                             contentType: .newPassword,
                             fieldText: $confirmPasswordFieldText)
            }
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

                Text("At least 8 characters".localized)
                    .font(Asset.AppFont.appSubheadline)
                    .foregroundStyle(validation.hasMinLength ? Asset.AppColor.isSuccess : Asset.AppColor.appSecondaryText)

                Spacer()
            }
            .animation(.easeInOut(duration: 0.25), value: validation.hasMinLength)

            HStack(alignment: .top) {
                Asset.AppImage.checkmark
                    .resizable()
                    .scaledToFit()
                    .frame(width: Asset.AppSpacing.sm, height: Asset.AppSpacing.sm)
                    .foregroundStyle(validation.isPasswordValid ? Asset.AppColor.isSuccess : Asset.AppColor.appSecondaryText)
                    .padding(.top, Asset.AppSpacing.sm / 2)

                Text("Uppercase, lowercase & number".localized)
                    .font(Asset.AppFont.appSubheadline)
                    .foregroundStyle(validation.isPasswordValid ? Asset.AppColor.isSuccess: Asset.AppColor.appSecondaryText)
            }
            .animation(.easeInOut(duration: 0.25), value: validation.isPasswordValid)
        }
        .padding(.vertical, Asset.AppSpacing.md)

    }

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            AppButton(title: "Sign Up",
                      style: .primary,
                      isLoading: isSigningUp,
                      isDisabled: !validation.isFormValid || !isPrivacyAccepted) {
                isSigningUp = true
                Task {
                    defer { isSigningUp = false }
                    await authManager.signUp(email: emailFieldText, password: passwordFieldText)

                    if authManager.errorMessage != nil {
                        showAlert = true
                    } else {
                        showSuccessAlert = true
                    }
                }
            }

            HStack {
                HStack {
                    Text("I have read the".localized)
                        .font(Asset.AppFont.appSubheadline)
                        .foregroundStyle(Asset.AppColor.appPrimaryText)

                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        Text("Privacy Policy".localized)
                            .fontWeight(.bold)
                            .foregroundStyle(Asset.AppColor.appPrimaryYellow)
                            .font(Asset.AppFont.appSubheadline)
                    }
                    .sheet(isPresented: $showPrivacyPolicy) {
                        SafariView(url: Self.privacyPolicyURL)
                    }
                }

                Spacer()

                Button {
                    isPrivacyAccepted.toggle()
                } label: {
                    isPrivacyAccepted ? Asset.AppImage.checkmarkSquare : Asset.AppImage.square
                }
                .foregroundStyle(isPrivacyAccepted ? Asset.AppColor.appPrimaryYellow : Asset.AppColor.appSecondaryText)
                .accessibilityLabel("I have read the Privacy Policy".localized)
                .accessibilityAddTraits(isPrivacyAccepted ? [.isSelected] : [])
            }
            .padding(.horizontal, Asset.AppSpacing.sm)

            HStack{
                Text("Already have an account?".localized)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)

                Spacer()

                Button {
                    authRouter.push(.signIn)
                } label: {
                    Text("Sign In".localized)
                        .font(Asset.AppFont.appHeadline)
                        .foregroundStyle(Asset.AppColor.appPrimaryYellow)

                }
            }
            .padding(.horizontal, Asset.AppSpacing.sm)
        }

    }
}
