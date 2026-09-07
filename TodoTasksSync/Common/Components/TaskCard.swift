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
        HStack(spacing: Asset.AppSpacing.md) {
            Group {
                if task.isCompleted {
                    Asset.AppImage.checkmarkCircle
                } else {
                    Asset.AppImage.circle
                }
            }
            .foregroundStyle(task.isCompleted ? Asset.AppColor.isSuccess : Asset.AppColor.appPrimraryYellow)

            VStack(alignment: .leading, spacing: Asset.AppSpacing.sm / 2) {
                Text(task.title)
                    .font(Asset.AppFont.appHeadline)
                    .foregroundStyle(task.isCompleted ? Asset.AppColor.appSecondaryText : Asset.AppColor.appPrimaryText)
                    .strikethrough(task.isCompleted)

                HStack(spacing: 4) {
                    Asset.AppImage.calendar
                        .foregroundStyle(task.isOverdue ? Asset.AppColor.isError : Asset.AppColor.appSecondaryText)
                        .font(Asset.AppFont.appCaption1)


                    Text(task.dueDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(Asset.AppFont.appCaption1)
                        .foregroundStyle(task.isOverdue ? Asset.AppColor.isError : Asset.AppColor.appSecondaryText)
                        .lineLimit(1)
                }
                .fixedSize()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if task.isOverdue {
                Text("Overdue".localized)
                    .font(Asset.AppFont.appCaption1)
                    .foregroundStyle(Asset.AppColor.isError)
                    .padding(.horizontal, Asset.AppSpacing.sm)
                    .padding(.vertical, 4)
                    .background(Asset.AppColor.isError.opacity(0.1), in: Capsule())
                    .fixedSize()
            }
        }
        .padding(Asset.AppSpacing.md)
        .frame(height: 76)
        .background {
            RoundedRectangle(cornerRadius: Asset.AppSpacing.md)
                .fill(Asset.AppColor.appSurface)
                .strokeBorder(task.isOverdue ? Asset.AppColor.isError : Asset.AppColor.appSeparator, lineWidth: 1)
        }
    }
}
