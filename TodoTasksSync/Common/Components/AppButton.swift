//
//  Components.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 29.07.26.
//

import SwiftUI

enum AppButtonStyle {
    case primary, secondary

    var background: Color {
        switch self {
        case .primary:
            return AppAsset.AppColor.appPrimraryYellow
        case .secondary:
            return AppAsset.AppColor.appBackground
        }
    }

    var fontColor: Color {
        switch self {
        case .primary:
            return AppAsset.AppColor.appPrimaryText
        case .secondary:
            return AppAsset.AppColor.appSecondaryText
        }
    }

    var borderColor: Color {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return AppAsset.AppColor.appSeparator
        }
    }
}

struct AppButton: View {
    let title: String
    let style: AppButtonStyle
    var isOverlayed: Bool = false
    let action: () -> Void


    var body: some View {
        Button(action: action) {
            HStack(spacing: AppAsset.AppSpacing.md) {
                if isOverlayed {
                    AppAsset.AppImage.AppGoogleLogo
                }

                Text(title)
                    .font(AppAsset.AppFont.appHeadline)
                    .foregroundStyle(style.fontColor)

            }
            .padding(.vertical, AppAsset.AppSpacing.md)

        }
        .frame(maxWidth: .infinity)
        .background(style.background)
        .cornerRadius(AppAsset.AppSpacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppAsset.AppSpacing.md)
                .stroke(style.borderColor, lineWidth: 0.6)
        )


    }
}
