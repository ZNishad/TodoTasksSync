//
//  Components.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 29.07.26.
//

import SwiftUI

enum AppButtonStyle {
    case primary, secondary, clean

    var background: Color {
        switch self {
        case .primary:
            return Asset.AppColor.appPrimaryYellow
        case .secondary:
            return Asset.AppColor.appBackground
        case .clean:
            return Asset.AppColor.appBackground
        }
    }

    var fontColor: Color {
        switch self {
        case .primary:
            return Asset.AppColor.appPrimaryText
        case .secondary:
            return Asset.AppColor.appSecondaryText
        case .clean:
            return Asset.AppColor.appPrimaryYellow
        }
    }

    var borderColor: Color {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return Asset.AppColor.appSeparator
        case .clean:
            return .clear
        }
    }
}

struct AppButton: View {
    let title: String
    let style: AppButtonStyle
    var isOverlayed: Bool = false
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    private var isInteractionBlocked: Bool {
        isDisabled || isLoading
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isOverlayed {
                    Asset.AppImage.appGoogleLogo
                        .offset(x: -Asset.AppSpacing.xxxl * 3)
                        .accessibilityHidden(true)
                }

                if isLoading {
                    LoadingDotsView()
                } else {
                    Text(title.localized)
                        .font(Asset.AppFont.appHeadline)
                        .foregroundStyle(style.fontColor)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, Asset.AppSpacing.md)
        }
        .disabled(isInteractionBlocked)
        .frame(minHeight: 55)
        .frame(maxWidth: .infinity)
        .background(isInteractionBlocked ? style.background.opacity(0.3) : style.background)
        .cornerRadius(Asset.AppSpacing.md)
        .animation(.easeInOut(duration: 0.25), value: isInteractionBlocked)
        .overlay(
            RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
                .stroke(style.borderColor, lineWidth: 0.6)
        )
        .accessibilityLabel(Text(title.localized))
    }
}
