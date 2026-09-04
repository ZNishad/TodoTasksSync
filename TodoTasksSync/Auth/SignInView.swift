//
//  SignInView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import SwiftUI

struct SignInView: View {

    @State private var emailFieldText: String = ""
    @State private var passwordFieldText: String = ""
    @State private var showForgotPassView: Bool = false
    @State private var isSigningIn = false
    @State private var isGoogleSigningIn = false
    @State private var showAlert = false

    @EnvironmentObject private var authRouter: AuthRouter
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        ScrollView {
            header
            mainSection
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
        .sheet(isPresented: $showForgotPassView) {
            ForgotPassView()
                .presentationDetents([.fraction(0.6)])
                .presentationBackground(Asset.AppColor.appBackground)
                .presentationDragIndicator(.visible)
        }
        .alert("Error".localized, isPresented: $showAlert) {
            Button("OK".localized) { }
        } message: {
            Text(authManager.errorMessage ?? "")
        }


    }
}

extension SignInView {

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .center, spacing: Asset.AppSpacing.md) {
            Asset.AppImage.signInHeader
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.bottom, Asset.AppSpacing.lg)

            VStack(spacing: Asset.AppSpacing.sm) {
                Text("Welcome Back")
                    .font(Asset.AppFont.appTitle1)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)

                Text("Sign in to continue")
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
                HStack(alignment: .top) {
                    Spacer()
                    Button {
                        showForgotPassView.toggle()
                    } label: {
                        Text("Forgot password?")
                            .font(Asset.AppFont.appHeadline)
                            .foregroundStyle(Asset.AppColor.appPrimraryYellow)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            AppButton(title: "Sign In".localized, style: .primary, isLoading: isSigningIn) {
                guard !isSigningIn else { return }

                isSigningIn = true

                Task {
                    defer { isSigningIn = false }

                    await authManager.signIn(email: emailFieldText, password: passwordFieldText)

                    if authManager.errorMessage != nil {
                        showAlert = true
                    }
                }
            }

            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Asset.AppColor.appSeparator)

                Text("or")
                    .font(Asset.AppFont.appFootnote)
                    .foregroundStyle(Asset.AppColor.appSeparator)

                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Asset.AppColor.appSeparator)
            }

            AppButton(title: "Continue with Google", style: .secondary, isOverlayed: true, isLoading: isGoogleSigningIn) {
                guard !isGoogleSigningIn else { return }

                isGoogleSigningIn = true

                Task {
                    defer { isGoogleSigningIn = false }

                    await authManager.signInWithGoogle()
                }
            }

            HStack{
                Text("No account?")
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)

                Button {
                    authRouter.push(.signUp)
                } label: {
                    Text("Sign Up")
                        .font(Asset.AppFont.appHeadline)
                        .foregroundStyle(Asset.AppColor.appPrimraryYellow)

                }
            }
        }
    }
}
