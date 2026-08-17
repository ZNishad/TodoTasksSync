//
//  Asset.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 29.07.26.
//

import Foundation
import SwiftUI

struct Asset {
    private init() {}

    struct AppColor {
        private init() {}

        static let appPrimraryYellow = SwiftUI.Color.primaryYellow
        static let appBackground = SwiftUI.Color.background
        static let appPrimaryText = SwiftUI.Color.primaryText
        static let appSecondaryText = SwiftUI.Color.secondaryText
        static let appSeparator = SwiftUI.Color.appSeparator
        static let appSurface = SwiftUI.Color.surface
        static let isError = SwiftUI.Color.red
        static let isSuccess = SwiftUI.Color.green

    }

    struct AppFont {
        private init() {}

        static let appLargeTitle = SwiftUI.Font.system(size: 34, weight: .bold)
        static let appTitle1 = SwiftUI.Font.system(size: 28, weight: .bold)
        static let appTitle2 = SwiftUI.Font.system(size: 22, weight: .bold)
        static let appTitle3 = SwiftUI.Font.system(size: 20, weight: .semibold)
        static let appHeadline = SwiftUI.Font.system(size: 17, weight: .semibold)
        static let appBody = SwiftUI.Font.system(size: 17, weight: .regular)
        static let appCallout = SwiftUI.Font.system(size: 16, weight: .regular)
        static let appSubheadline = SwiftUI.Font.system(size: 15, weight: .regular)
        static let appFootnote = SwiftUI.Font.system(size: 13, weight: .regular)
        static let appCaption1 = SwiftUI.Font.system(size: 12, weight: .regular)
        static let appCaption2 = SwiftUI.Font.system(size: 11, weight: .regular)
    }

    struct AppSpacing {
        private init() {}

        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 48

    }

    struct AppImage {
        private init() {}

        static let appGoogleLogo = Image(.googleLogo)
        static let welcomeHeader = Image(.welcomeViewHeader)
        static let signInHeader = Image(.signInViewHeader)
        static let signUpHeader = Image(.signUpViewHeader)
        static let checkmark = Image(systemName: "checkmark")
        static let forgotPassHeader = Image(.forgotPassViewHeader)
        static let checkmarkSquare = Image(systemName: "checkmark.square")
        static let square = Image(systemName: "square")
        static let profile = Image(systemName: "person")
        static let circle = Image(systemName: "circle")
        static let checkmarkCircle = Image(systemName: "checkmark.circle.fill")
        static let trash = Image(systemName: "trash")
        static let calendar = Image(systemName: "calendar")
        static let plus = Image(systemName: "plus")
        static let clock = Image(systemName: "clock")
        static let history = Image(systemName: "clock.arrow.circlepath")
        static let backArrow = Image(systemName: "arrow.uturn.backward")
        static let option = Image(systemName: "ellipsis")
        static let noTask = Image(.noTask)
        static let noHistory = Image(.noHistory)

    }

}
