//
//  Asset.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 29.07.26.
//

import Foundation
import SwiftUI

struct AppAsset {
    private init() {}

    struct AppColor {
        private init() {}

        static let appPrimraryYellow = SwiftUI.Color.primaryYellow
        static let appBackground = SwiftUI.Color.background
        static let appPrimaryText = SwiftUI.Color.primaryText
        static let appSecondaryText = SwiftUI.Color.secondaryText
        static let appSeparator = SwiftUI.Color.appSeparator
        static let appSurface = SwiftUI.Color.surface

    }

    struct AppFont {
        private init() {}

        static let appLargeTitle = SwiftUI.Font.system(size: 34, weight: .bold)
        static let appHeadline = SwiftUI.Font.system(size: 17, weight: .semibold)
        static let appBody = SwiftUI.Font.system(size: 17, weight: .regular)
        static let appSubheadline = SwiftUI.Font.system(size: 15, weight: .regular)
        static let appCaption = SwiftUI.Font.system(size: 13, weight: .regular)
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

        static let AppGoogleLogo = SwiftUI.Image(.googleLogo)
        static let AppAppleLogo = SwiftUI.Image("apple.logo")
    }

}
