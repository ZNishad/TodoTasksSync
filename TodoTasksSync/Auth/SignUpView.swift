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
    @State private var isProvicyAccepted: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var showPrivacyPolicy = false


    @EnvironmentObject private var authRouter: AuthRouter
    @EnvironmentObject private var authManager: AuthManager



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
                             isError: !validation.isEmailValid && !emailFieldText.isEmpty,
                             fieldText: $emailFieldText)

            }

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Password")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Enter your password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             fieldText: $passwordFieldText)
            }

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm) {
                Text("Confirm password")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                AppTextField(placeholder: "Confirm your password".localized,
                             iconName: "lock.fill",
                             isSecured: true,
                             isError: !validation.passwordsMatch && !passwordFieldText.isEmpty,
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

                Text("At least 8 characters")
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

                Text("Uppercase, lowercase & number")
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
            AppButton(title: "Sign Up", style: .primary, isLoading: isSigningUp, isDisabled: !validation.isFormValid || !isProvicyAccepted) {
                Task {
                    isSigningUp = true
                    await authManager.signUp(email: emailFieldText, password: passwordFieldText)
                    isSigningUp = false

                    if authManager.errorMessage != nil {
                        showAlert = true
                    } else {
                        showSuccessAlert = true
                    }
                }
            }
            .disabled(!validation.isFormValid || !isProvicyAccepted)

            HStack() {
                HStack() {
                    Text("I have read the")
                        .font(.system(size: 14))
                        .foregroundStyle(Asset.AppColor.appPrimaryText)


                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        Text("Privacy Policy")
                            .fontWeight(.bold)
                            .foregroundStyle(Asset.AppColor.appPrimraryYellow)
                            .font(.system(size: 14))
                    }
                    .sheet(isPresented: $showPrivacyPolicy) {
                        SafariView(url: URL(string: "https://znishad.github.io/todotaskssync-privacy/")!)
                    }
                }

                Spacer()

                Button {
                    isProvicyAccepted.toggle()
                } label: {
                    isProvicyAccepted ? Asset.AppImage.checkmarkSquare : Asset.AppImage.square
                }
                .foregroundStyle(isProvicyAccepted ? Asset.AppColor.appPrimraryYellow : Asset.AppColor.appSecondaryText)
            }
            .padding(.horizontal, Asset.AppSpacing.sm)

            HStack{
                Text("Already have an account?")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)

                Spacer()

                Button {
                    authRouter.push(.signIn)
                } label: {
                    Text("Sign In")
                        .font(Asset.AppFont.appHeadline)
                        .foregroundStyle(Asset.AppColor.appPrimraryYellow)

                }
            }
            .padding(.horizontal, Asset.AppSpacing.sm)
        }

    }
}
