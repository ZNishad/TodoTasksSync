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

        static let appPrimaryYellow = SwiftUI.Color.primaryYellow
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

        static let appLargeTitle = SwiftUI.Font.system(.largeTitle, weight: .bold)       // 34
        static let appTitle1 = SwiftUI.Font.system(.title, weight: .bold)                // 28
        static let appTitle2 = SwiftUI.Font.system(.title2, weight: .bold)               // 22
        static let appTitle3 = SwiftUI.Font.system(.title3, weight: .semibold)           // 20
        static let appHeadline = SwiftUI.Font.system(.headline, weight: .semibold)       // 17
        static let appBody = SwiftUI.Font.system(.body, weight: .regular)                // 17
        static let appCallout = SwiftUI.Font.system(.callout, weight: .regular)          // 16
        static let appSubheadline = SwiftUI.Font.system(.subheadline, weight: .regular)  // 15
        static let appFootnote = SwiftUI.Font.system(.footnote, weight: .regular)        // 13
        static let appCaption1 = SwiftUI.Font.system(.caption, weight: .regular)         // 12
        static let appCaption2 = SwiftUI.Font.system(.caption2, weight: .regular)        // 11
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
        static let headerClock = Image(.clock)
        static let headerSuccess = Image(.successIMG)
        static let headerWarning = Image(.warningIMG)

    }

}
