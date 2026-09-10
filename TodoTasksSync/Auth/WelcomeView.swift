//
//  WelcomeView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject private var authRouter: AuthRouter

    var body: some View {
        VStack {
            header
            mainSection
            footer
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

            Text("Welcome to".localized)
                .foregroundStyle(Asset.AppColor.appSecondaryText)
                .font(Asset.AppFont.appTitle2)

            appNameTitle

            Text("Plan your day. Stay focused. Get things done".localized)
                .multilineTextAlignment(.center)
                .font(Asset.AppFont.appCallout)
                .foregroundStyle(Asset.AppColor.appSecondaryText)
                .lineLimit(2)
        }
        .padding(.bottom, Asset.AppSpacing.xxxl)
    }

    private var appNameTitle: some View {
        (
            Text("To Do & Tasks").foregroundStyle(Asset.AppColor.appPrimaryText)
            + Text(": Sync").foregroundStyle(Asset.AppColor.appPrimaryYellow)
        )
        .font(Asset.AppFont.appLargeTitle)
        .accessibilityLabel("To Do & Tasks: Sync")
    }

    @ViewBuilder
    private var mainSection: some View {
        VStack(alignment: .center, spacing: Asset.AppSpacing.md) {
            AppButton(title: "Sign In", style: .primary) {
                authRouter.push(.signIn)

            }

            AppButton(title: "Sign Up", style: .secondary) {
                authRouter.push(.signUp)
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundStyle(Asset.AppColor.appPrimaryYellow)
                .accessibilityHidden(true)

            Text("Your tasks, everywhere.".localized)
                .font(Asset.AppFont.appFootnote)
                .foregroundStyle(Asset.AppColor.appSecondaryText)
        }
        .padding(.top, Asset.AppSpacing.lg)
    }
}
