//
//  AppTextField.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 29.07.26.
//

import SwiftUI

struct AppTextField: View {
    let placeholder: String
    let iconName: String?
    var isSecured: Bool = false
    @State private var isPasswordVisible: Bool = false

    @Binding var fieldText: String

    var body: some View {
        HStack(alignment: .center) {
            if let iconName {
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: AppAsset.AppSpacing.md, height: AppAsset.AppSpacing.md)
                    .foregroundStyle(AppAsset.AppColor.appSecondaryText)
                    .padding(.leading, AppAsset.AppSpacing.md)
            }

            if !isSecured {
                TextField("", text: $fieldText, prompt: Text(placeholder.capitalized).foregroundStyle(AppAsset.AppColor.appSecondaryText))
                    .frame(height: AppAsset.AppSpacing.lg)
            } else {
                ZStack {
                    TextField("", text: $fieldText, prompt: Text(placeholder.capitalized).foregroundStyle(AppAsset.AppColor.appSecondaryText))
                        .frame(height: AppAsset.AppSpacing.lg)
                        .opacity(isPasswordVisible ? 1 : 0)
                    SecureField("", text: $fieldText, prompt: Text(placeholder.capitalized).foregroundStyle(AppAsset.AppColor.appSecondaryText))
                        .frame(height: AppAsset.AppSpacing.lg)
                        .opacity(isPasswordVisible ? 0 : 1)
                }

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundStyle(AppAsset.AppColor.appSecondaryText)
                }
                .padding(.horizontal, AppAsset.AppSpacing.md)
            }
        }
        .frame(maxWidth: .infinity)
        .background(AppAsset.AppColor.appBackground)
        .padding(.vertical, AppAsset.AppSpacing.md)
        .cornerRadius(AppAsset.AppSpacing.md)
        .overlay {
            RoundedRectangle(cornerRadius: AppAsset.AppSpacing.md)
                .stroke(AppAsset.AppColor.appSeparator, lineWidth: 0.6)
        }
    }
}
