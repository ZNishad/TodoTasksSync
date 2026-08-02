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
            return Asset.AppColor.appPrimraryYellow
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
            return Asset.AppColor.appPrimraryYellow
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


    var body: some View {
        Button(action: action) {
            HStack(spacing: Asset.AppSpacing.md) {
                if isOverlayed {
                    Asset.AppImage.appGoogleLogo
                        .padding(.leading, Asset.AppSpacing.md)
                }

                if isLoading {
                    LoadingDotsView()
                } else {
                    Text(title.localized)
                        .font(Asset.AppFont.appHeadline)
                        .foregroundStyle(style.fontColor)
                        .frame(maxWidth: .infinity)
                }

                if isOverlayed {
                    Spacer()
                }

            }
            .padding(.vertical, Asset.AppSpacing.md)

        }
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(isDisabled ? style.background.opacity(0.3) : style.background)
        .cornerRadius(Asset.AppSpacing.md)
        .animation(.spring(duration: 0.7), value: isDisabled)
        .overlay(
            RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
                .stroke(style.borderColor, lineWidth: 0.6)
        )


    }
}
