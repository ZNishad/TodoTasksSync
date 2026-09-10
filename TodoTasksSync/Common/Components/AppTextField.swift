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
    var isError: Bool = false
    /// Drives autofill and the keyboard's suggestion bar — must match what the field
    /// actually holds, so it is supplied per call site instead of being hard-coded.
    var contentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .never
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
                    .accessibilityHidden(true)
            }

            if !isSecured {
                styled(
                    TextField("", text: $fieldText, prompt: promptText)
                )
            } else {
                ZStack {
                    styled(
                        TextField("", text: $fieldText, prompt: promptText)
                    )
                    .opacity(isPasswordVisible ? 1 : 0)

                    styled(
                        SecureField("", text: $fieldText, prompt: promptText)
                    )
                    .opacity(isPasswordVisible ? 0 : 1)
                }

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundStyle(Asset.AppColor.appSecondaryText)
                }
                .padding(.horizontal, Asset.AppSpacing.md)
                .accessibilityLabel(isPasswordVisible ? "Hide password".localized : "Show password".localized)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Asset.AppSpacing.md)
        .background(Asset.AppColor.appSurface)
        .cornerRadius(Asset.AppSpacing.md)
        .overlay {
            RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
                .stroke(isError ? Asset.AppColor.isError : Asset.AppColor.appSeparator, lineWidth: 1)
                .animation(.easeInOut(duration: 0.25), value: isError)
        }
    }

    private var promptText: Text {
        Text(placeholder).foregroundStyle(Asset.AppColor.appSecondaryText)
    }

    private func styled(_ field: some View) -> some View {
        field
            .frame(minHeight: Asset.AppSpacing.lg)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()
            .textContentType(contentType)
    }
}
