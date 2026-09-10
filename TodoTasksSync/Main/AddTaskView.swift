//
//  AddTaskView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 07.08.26.
//

import SwiftUI

struct AddTaskView: View {
    // End of today rather than "right now", which would create a task that is
    // already at its deadline and whose reminder time has passed.
    @State private var title: String = ""
    @State private var dueDate: Date = Date().endOfDay

    @EnvironmentObject private var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: Asset.AppSpacing.lg) {
            Text("Add new Task".localized)
                .font(Asset.AppFont.appTitle1)
                .foregroundStyle(Asset.AppColor.appPrimaryText)

            AppTextField(placeholder: "What do you need to do?".localized,
                         iconName: "list.bullet.clipboard",
                         autocapitalization: .sentences,
                         fieldText: $title)

            DatePicker(
                "Due date".localized,
                selection: $dueDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .font(Asset.AppFont.appBody)
            .onChange(of: dueDate) {
                hideKeyboard()
            }

            AppButton(title: "Add Task", style: .primary, isDisabled: trimmedTitle.isEmpty) {
                taskManager.addTask(title: trimmedTitle, dueDate: dueDate)
                dismiss()
            }
        }
        .padding(Asset.AppSpacing.lg)
    }
}
