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

        static let appGoogleLogo = SwiftUI.Image(.googleLogo)
        static let appAppleLogo = SwiftUI.Image("apple.logo")
        static let welcomeHeader = SwiftUI.Image(.welcomeViewHeader)
        static let signInHeader = SwiftUI.Image(.signInViewHeader)
        static let signUpHeader = SwiftUI.Image(.signUpViewHeader)
        static let checkmark = SwiftUI.Image(systemName: "checkmark")
    }

}
