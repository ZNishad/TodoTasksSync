//
//  Helpers.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 02.08.26.
//

import SwiftUI

@MainActor
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

nonisolated extension Date {
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
}

nonisolated extension String {
    func withCharacterLimit(_ limit: Int) -> String {
        "\(self) (\("max".localized) \(limit))"
    }
}

nonisolated extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
