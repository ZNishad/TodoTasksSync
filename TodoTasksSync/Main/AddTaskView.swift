//
//  AddTaskView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 07.08.26.
//

import SwiftUI

struct AddTaskView: View {
    @State private var title: String = ""
    @State private var dueDate: Date = Date()

    @EnvironmentObject private var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isTitleTooLong: Bool {
        trimmedTitle.count > TodoTask.titleLimit
    }

    private var canSubmit: Bool {
        !trimmedTitle.isEmpty && !isTitleTooLong
    }

    var body: some View {
        VStack(spacing: Asset.AppSpacing.lg) {
            Text("Add new Task".localized)
                .font(Asset.AppFont.appTitle1)
                .foregroundStyle(Asset.AppColor.appPrimaryText)

            VStack(alignment: .trailing, spacing: Asset.AppSpacing.sm / 2) {
                AppTextField(
                    placeholder: "What do you need to do?".localized
                        .withCharacterLimit(TodoTask.titleLimit),
                    iconName: "list.bullet.clipboard",
                    isError: isTitleTooLong,
                    autocapitalization: .sentences,
                    fieldText: $title
                )

                Text("\(trimmedTitle.count)/\(TodoTask.titleLimit)")
                    .font(Asset.AppFont.appCaption1)
                    .foregroundStyle(
                        isTitleTooLong ? Asset.AppColor.isError : Asset.AppColor.appSecondaryText
                    )
            }

            DatePicker(
                "Due date".localized,
                selection: $dueDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .font(Asset.AppFont.appBody)
            .onChange(of: dueDate) {
                hideKeyboard()
            }

            AppButton(title: "Add Task", style: .primary, isDisabled: !canSubmit) {
                taskManager.addTask(title: trimmedTitle, dueDate: dueDate)
                dismiss()
            }
        }
        .padding(Asset.AppSpacing.lg)
    }
}
