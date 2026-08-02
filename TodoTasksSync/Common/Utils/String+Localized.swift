//
//  String+Localized.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 28.07.26.
//

import Foundation

extension String {
    var localized: String {
        String(localized: LocalizationValue(self))
    }
}
