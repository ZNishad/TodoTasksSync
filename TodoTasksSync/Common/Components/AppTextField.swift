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
                    .frame(width: Asset.AppSpacing.md, height: Asset.AppSpacing.md)
                    .foregroundStyle(Asset.AppColor.appSecondaryText)
                    .padding(.leading, Asset.AppSpacing.md)
            }

            if !isSecured {
                TextField("", text: $fieldText, prompt: Text(placeholder.capitalized).foregroundStyle(Asset.AppColor.appSecondaryText))
                    .frame(height: Asset.AppSpacing.lg)
            } else {
                ZStack {
                    TextField("", text: $fieldText, prompt: Text(placeholder.capitalized).foregroundStyle(Asset.AppColor.appSecondaryText))
                        .frame(height: Asset.AppSpacing.lg)
                        .opacity(isPasswordVisible ? 1 : 0)
                    SecureField("", text: $fieldText, prompt: Text(placeholder.capitalized).foregroundStyle(Asset.AppColor.appSecondaryText))
                        .frame(height: Asset.AppSpacing.lg)
                        .opacity(isPasswordVisible ? 0 : 1)
                }

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundStyle(Asset.AppColor.appSecondaryText)
                }
                .padding(.horizontal, Asset.AppSpacing.md)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Asset.AppSpacing.md)
        .background(Asset.AppColor.appSurface)
        .cornerRadius(Asset.AppSpacing.md)
        .overlay {
            RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
                .stroke(Asset.AppColor.appSeparator, lineWidth: 1)
        }
    }
}
