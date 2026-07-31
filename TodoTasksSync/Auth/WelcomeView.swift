//
//  WelcomeView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import SwiftUI


struct WelcomeView: View {

    @EnvironmentObject private var authRouter: AuthRouter

    @State private var isSigningIn: Bool = false
    @State private var isSigningUp: Bool = false

    var body: some View {
        VStack {
            header
            mainSection
            footer
//            Spacer()
        }
        .padding()
    }
}

extension WelcomeView {
    @ViewBuilder
    private var header: some View {
        VStack(alignment: .center, spacing: Asset.AppSpacing.sm) {
            Asset.AppImage.welcomeHeader
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding(.bottom, Asset.AppSpacing.lg)

            Text("Welcome to")
                .foregroundStyle(Asset.AppColor.appSecondaryText)
                .font(Asset.AppFont.appTitle2)

            Text("To Do & Tasks\(Text(": Sync").foregroundStyle(Asset.AppColor.appPrimraryYellow))")
                .font(Asset.AppFont.appLargeTitle)
                .foregroundStyle(Asset.AppColor.appPrimaryText)

            Text("Plan your day. Stay focused. Get things done")
                .multilineTextAlignment(.center)
                .font(Asset.AppFont.appCallout)
                .foregroundStyle(Asset.AppColor.appSecondaryText)
                .lineLimit(2)
        }
        .padding(.bottom, Asset.AppSpacing.xxxl)
    }

    @ViewBuilder
    private var mainSection: some View {
        VStack(alignment: .center, spacing: Asset.AppSpacing.md) {
            AppButton(title: "Sign In", style: .primary, isLoading: isSigningIn) {
                isSigningIn = true
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        authRouter.push(.signIn)
                        isSigningIn = false
                    }

            }

            AppButton(title: "Sign Up", style: .secondary, isLoading: isSigningUp) {
                isSigningUp = true
                    Task {
                        try? await Task.sleep(for: .seconds(1))
                        authRouter.push(.signUp)
                        isSigningUp = false
                    }

            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundStyle(Asset.AppColor.appPrimraryYellow)

            Text("Your tasks, everywhere.")
                .font(Asset.AppFont.appFootnote)
                .foregroundStyle(Asset.AppColor.appSecondaryText)
        }
        .padding(.top, Asset.AppSpacing.lg)
    }
}

#Preview {
    WelcomeView()
}
