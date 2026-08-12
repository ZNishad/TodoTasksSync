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
    @State private var showDatePicker = false

    @EnvironmentObject private var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Asset.AppSpacing.lg) {
            Text("Add new Task")
                .font(Asset.AppFont.appTitle1)
                .foregroundStyle(Asset.AppColor.appPrimaryText)

            AppTextField(placeholder: "What do you need to do?".localized,
                         iconName: "list.bullet.clipboard",
                         fieldText: $title)


            DatePicker(
                "Due date".localized,
                selection: $dueDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .onChange(of: dueDate) {
                hideKeyboard()
            }

            

            AppButton(title: "Add Task", style: .primary, isDisabled: title.isEmpty) {
                taskManager.addTask(title: title, dueDate: dueDate)
                dismiss()
            }
            .disabled(title.isEmpty)
        }
        .padding(Asset.AppSpacing.lg)
    }
}
