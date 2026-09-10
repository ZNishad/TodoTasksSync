//
//  TaskDetailView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 07.09.26.
//

import SwiftUI

struct TaskDetailView: View {

    let task: TodoTask

    @EnvironmentObject private var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var draftTitle = ""
    @State private var draftDueDate = Date()

    private var currentTask: TodoTask {
        taskManager.tasks.first { $0.id == task.id } ?? task
    }

    private var trimmedDraftTitle: String {
        draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isTitleTooLong: Bool {
        trimmedDraftTitle.count > TodoTask.titleLimit
    }

    private var canSave: Bool {
        guard !trimmedDraftTitle.isEmpty, !isTitleTooLong else { return false }
        return trimmedDraftTitle != currentTask.title || draftDueDate != currentTask.dueDate
    }

    var body: some View {
        VStack(spacing: Asset.AppSpacing.lg) {
            headerImage

            VStack(spacing: Asset.AppSpacing.sm) {
                statusBadge
                titleSection
            }

            detailsCard

            Spacer(minLength: Asset.AppSpacing.md)

            actions
        }
        .padding(Asset.AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.25), value: isEditing)
    }
}

// MARK: - Sections

private extension TaskDetailView {

    var headerImage: some View {
        statusImage
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
            .padding(.top, Asset.AppSpacing.md)
            .accessibilityHidden(true)
    }

    var statusBadge: some View {
        Text(statusText)
            .font(Asset.AppFont.appCaption1)
            .foregroundStyle(statusColor)
            .padding(.horizontal, Asset.AppSpacing.sm)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1), in: Capsule())
    }

    @ViewBuilder
    var titleSection: some View {
        if isEditing {
            VStack(alignment: .trailing, spacing: Asset.AppSpacing.sm / 2) {
                AppTextField(
                    placeholder: "Task title".localized
                        .withCharacterLimit(TodoTask.titleLimit),
                    iconName: "list.bullet.clipboard",
                    isError: trimmedDraftTitle.isEmpty || isTitleTooLong,
                    autocapitalization: .sentences,
                    fieldText: $draftTitle
                )

                Text("\(trimmedDraftTitle.count)/\(TodoTask.titleLimit)")
                    .font(Asset.AppFont.appCaption1)
                    .foregroundStyle(
                        isTitleTooLong ? Asset.AppColor.isError : Asset.AppColor.appSecondaryText
                    )
            }
        } else {
            Text(currentTask.title)
                .font(Asset.AppFont.appTitle2)
                .foregroundStyle(Asset.AppColor.appPrimaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var detailsCard: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            dueDateRow

            detailRow(
                icon: "plus.circle",
                title: "Created".localized,
                value: currentTask.createdAt.formatted(date: .abbreviated, time: .shortened)
            )

            if let completedAt = currentTask.completedAt {
                Divider()

                detailRow(
                    icon: "checkmark.circle",
                    title: "Completed".localized,
                    value: completedAt.formatted(date: .abbreviated, time: .shortened)
                )
            }
        }
        .padding(Asset.AppSpacing.md)
        .background(
            Asset.AppColor.appSurface,
            in: RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
        )
    }

    @ViewBuilder
    var dueDateRow: some View {
        if isEditing {
            HStack(spacing: Asset.AppSpacing.md) {
                rowIcon("calendar")

                DatePicker(
                    "Due date".localized,
                    selection: $draftDueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .font(Asset.AppFont.appSubheadline)
                .foregroundStyle(Asset.AppColor.appSecondaryText)
                .onChange(of: draftDueDate) {
                    hideKeyboard()
                }
            }

            Divider()
        } else if let dueDate = currentTask.dueDate {
            detailRow(
                icon: "calendar",
                title: "Due date".localized,
                value: dueDate.formatted(date: .abbreviated, time: .shortened),
                subtitle: dueDate.formatted(.relative(presentation: .named))
            )

            Divider()
        }
    }

    @ViewBuilder
    var actions: some View {
        if isEditing {
            HStack(spacing: Asset.AppSpacing.md) {
                AppButton(title: "Cancel", style: .clean) {
                    hideKeyboard()
                    isEditing = false
                }

                AppButton(title: "Save changes", style: .primary, isDisabled: !canSave) {
                    hideKeyboard()
                    taskManager.updateTask(
                        currentTask,
                        title: draftTitle,
                        dueDate: draftDueDate
                    )
                    isEditing = false
                }
            }
        } else {
            AppButton(title: "Edit", style: .secondary) {
                draftTitle = currentTask.title
                draftDueDate = currentTask.dueDate ?? Date().endOfDay
                isEditing = true
            }
        }
    }
}

// MARK: - Row building blocks

private extension TaskDetailView {

    func rowIcon(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(Asset.AppFont.appBody)
            .foregroundStyle(Asset.AppColor.appPrimaryYellow)
            .frame(width: 24)
            .accessibilityHidden(true)
    }

    func detailRow(icon: String, title: String, value: String, subtitle: String? = nil) -> some View {
        HStack(spacing: Asset.AppSpacing.md) {
            rowIcon(icon)

            Text(title)
                .font(Asset.AppFont.appSubheadline)
                .foregroundStyle(Asset.AppColor.appSecondaryText)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(Asset.AppFont.appSubheadline)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(Asset.AppFont.appCaption2)
                        .foregroundStyle(currentTask.isOverdue ? Asset.AppColor.isError : Asset.AppColor.appSecondaryText)
                        .lineLimit(1)
                }
            }
        }
    }
}

// MARK: - Status

private extension TaskDetailView {

    var statusText: String {
        if currentTask.isCompleted {
            return "Completed".localized
        } else if currentTask.isOverdue {
            return "Overdue".localized
        } else {
            return "Active".localized
        }
    }

    var statusImage: Image {
        if currentTask.isCompleted {
            return Asset.AppImage.headerSuccess
        } else if currentTask.isOverdue {
            return Asset.AppImage.headerWarning
        } else {
            return Asset.AppImage.headerClock
        }
    }

    var statusColor: Color {
        if currentTask.isCompleted {
            return Asset.AppColor.isSuccess
        } else if currentTask.isOverdue {
            return Asset.AppColor.isError
        } else {
            return Asset.AppColor.appPrimaryYellow
        }
    }
}
