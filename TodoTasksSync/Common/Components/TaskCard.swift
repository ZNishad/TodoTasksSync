//
//  TaskCard.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 05.08.26.
//

import SwiftUI

struct TaskCard: View {

    let task: TodoTask

    var body: some View {
        taskCard
    }
}

extension TaskCard {

    @ViewBuilder
    private var taskCard: some View {
        HStack(spacing: Asset.AppSpacing.md) {

            checkmark

            taskInfo

            Spacer()

            if task.isOverdue {
                overdueBadge
            }
        }
        .padding(Asset.AppSpacing.md)
        .background(Asset.AppColor.appSurface)
        .clipShape(
            RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
        )
        .overlay {
            RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
                .stroke(borderColor, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var checkmark: some View {
        Group {
            if task.isCompleted {
                Asset.AppImage.checkmarkCircle
            } else {
                Asset.AppImage.circle
            }
        }
        .foregroundStyle(checkmarkColor)
    }

    @ViewBuilder
    private var taskInfo: some View {
        VStack(alignment: .leading, spacing: Asset.AppSpacing.sm / 2) {

            Text(task.title)
                .font(Asset.AppFont.appHeadline)
                .foregroundStyle(titleColor)
                .strikethrough(task.isCompleted)

            if let dueDate = task.dueDate {
                HStack(spacing: 4) {

                    Asset.AppImage.calendar

                    Text(
                        dueDate.formatted(
                            date: .abbreviated,
                            time: .omitted
                        )
                    )
                }
                .font(Asset.AppFont.appCaption1)
                .foregroundStyle(subtitleColor)
            }
        }
    }

    @ViewBuilder
    private var overdueBadge: some View {
        Text("Overdue".localized)
            .font(Asset.AppFont.appCaption1)
            .foregroundStyle(Asset.AppColor.isError)
            .padding(.horizontal, Asset.AppSpacing.sm)
            .padding(.vertical, 4)
            .background(
                Asset.AppColor.isError.opacity(0.1)
            )
            .clipShape(Capsule())
    }
}

private extension TaskCard {

    var titleColor: Color {
        task.isCompleted
            ? Asset.AppColor.appSecondaryText
            : Asset.AppColor.appPrimaryText
    }

    var subtitleColor: Color {
        task.isOverdue
            ? Asset.AppColor.isError
            : Asset.AppColor.appSecondaryText
    }

    var checkmarkColor: Color {
        task.isCompleted
            ? Asset.AppColor.isSuccess
            : Asset.AppColor.appPrimraryYellow
    }

    var borderColor: Color {
        task.isOverdue
            ? Asset.AppColor.isError
        
            : Asset.AppColor.appSeparator
    }
}

#Preview("Normal") {
    TaskCard(
        task: TodoTask(
            title: "Finish TaskCard UI",
            isCompleted: false,
            createdAt: .now,
            dueDate: .now.addingTimeInterval(60 * 60 * 2),
            completedAt: nil,
            userId: "preview"
        )
    )
    .padding()
    .background(Asset.AppColor.appBackground)
}

#Preview("Completed") {
    TaskCard(
        task: TodoTask(
            title: "Implement Firebase Auth",
            isCompleted: true,
            createdAt: .now,
            dueDate: .now,
            completedAt: .now,
            userId: "preview"
        )
    )
    .padding()
    .background(Asset.AppColor.appBackground)
}

#Preview("Overdue") {
    TaskCard(
        task: TodoTask(
            title: "Publish App",
            isCompleted: false,
            createdAt: .now,
            dueDate: .now.addingTimeInterval(-(60 * 60 * 24)),
            completedAt: nil,
            userId: "preview"
        )
    )
    .padding()
    .background(Asset.AppColor.appBackground)
}
