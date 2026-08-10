//
//  FormVaildation.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 02.08.26.
//

import Foundation

struct FormValidation {
    let name: String
    let email: String
    let password: String
    let confirmPassword: String

    // MARK: - Name

        var isNameValid: Bool {
            name.filter { $0.isLetter }.count >= 2
        }

    // MARK: - Email

    var isEmailValid: Bool {
        guard !email.isEmpty else { return false }
        let emailPattern = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: emailPattern) != nil
    }

    // MARK: - Password requirements

    var hasMinLength: Bool {
        password.count >= 8
    }

    var hasUppercase: Bool {
        password.contains(where: { $0.isUppercase })
    }

    var hasLowercase: Bool {
        password.contains(where: { $0.isLowercase })
    }

    var hasNumber: Bool {
        password.contains(where: { $0.isNumber })
    }

    var isPasswordValid: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasNumber
    }

    // MARK: - Confirm password

    var passwordsMatch: Bool {
        !confirmPassword.isEmpty && password == confirmPassword
    }

    // MARK: - Overall form validity

    var isFormValid: Bool {
        isEmailValid && isPasswordValid && passwordsMatch
    }
}
