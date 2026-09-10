//
//  TaskDetailView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 07.09.26.
//

import SwiftUI

struct TaskDetailView: View {

    let task: TodoTask

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Asset.AppSpacing.lg) {
            headerImage

            VStack(spacing: Asset.AppSpacing.sm) {
                statusBadge

                Text(task.title)
                    .font(Asset.AppFont.appTitle2)
                    .foregroundStyle(Asset.AppColor.appPrimaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            detailsCard

            Spacer()
        }
        .padding(Asset.AppSpacing.lg)
        .frame(maxWidth: .infinity)
    }
}

private extension TaskDetailView {

    var headerImage: some View {
        statusImage
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
            .padding(.top, Asset.AppSpacing.md)
    }

    var statusBadge: some View {
        Text(statusText)
            .font(Asset.AppFont.appCaption1)
            .foregroundStyle(statusColor)
            .padding(.horizontal, Asset.AppSpacing.sm)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1), in: Capsule())
    }

    var detailsCard: some View {
        VStack(spacing: Asset.AppSpacing.md) {
            if let dueDate = task.dueDate {
                detailRow(
                    icon: "calendar",
                    title: "Due date".localized,
                    value: dueDate.formatted(date: .abbreviated, time: .shortened),
                    subtitle: dueDate.formatted(.relative(presentation: .named))
                )

                Divider()
            }

            detailRow(
                icon: "plus.circle",
                title: "Created".localized,
                value: task.createdAt.formatted(date: .abbreviated, time: .shortened)
            )

            if let completedAt = task.completedAt {
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

    func detailRow(icon: String, title: String, value: String, subtitle: String? = nil) -> some View {
        HStack(spacing: Asset.AppSpacing.md) {
            Image(systemName: icon)
                .font(Asset.AppFont.appBody)
                .foregroundStyle(Asset.AppColor.appPrimaryYellow)
                .frame(width: 24)

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
                        .foregroundStyle(task.isOverdue ? Asset.AppColor.isError : Asset.AppColor.appSecondaryText)
                        .lineLimit(1)
                }
            }
        }
    }

    var statusText: String {
        if task.isCompleted {
            return "Completed".localized
        } else if task.isOverdue {
            return "Overdue".localized
        } else {
            return "Active".localized
        }
    }

    var statusImage: Image {
        if task.isCompleted {
            return Asset.AppImage.headerSuccess
        } else if task.isOverdue {
            return Asset.AppImage.headerWarning
        } else {
            return Asset.AppImage.headerClock
        }
    }

    var statusColor: Color {
        if task.isCompleted {
            return Asset.AppColor.isSuccess
        } else if task.isOverdue {
            return Asset.AppColor.isError
        } else {
            return Asset.AppColor.appPrimaryYellow
        }
    }
}
