//
//  TodoTasksSyncTests.swift
//  TodoTasksSyncTests
//
//  Created by Nishad Zulfuqarli on 27.07.26.
//

import Testing
import Foundation
@testable import TodoTasksSync

// MARK: - Helpers

@MainActor
private func makeTask(
    id: String = UUID().uuidString,
    title: String = "Task",
    isCompleted: Bool = false,
    createdAt: Date = Date(),
    dueDate: Date? = nil,
    completedAt: Date? = nil,
    userId: String = "user"
) -> TodoTask {
    TodoTask(
        id: id,
        title: title,
        isCompleted: isCompleted,
        createdAt: createdAt,
        dueDate: dueDate,
        completedAt: completedAt,
        userId: userId
    )
}

/// Fixed reference point so nothing depends on when the suite runs.
private let noon = Calendar.current.date(
    from: DateComponents(year: 2026, month: 6, day: 15, hour: 12, minute: 0)
)!

private func offset(_ interval: TimeInterval) -> Date {
    noon.addingTimeInterval(interval)
}

private let hour: TimeInterval = 3600
private let day: TimeInterval = 86_400

// MARK: - EmailValidator

@Suite("EmailValidator")
struct EmailValidatorTests {

    @Test("accepts well-formed addresses", arguments: [
        "user@example.com",
        "first.last@example.co.uk",
        "user+tag@example.com",
        "u_s-e%r@sub.domain.io"
    ])
    func acceptsValid(_ email: String) {
        #expect(EmailValidator.isValid(email))
    }

    @Test("rejects malformed addresses", arguments: [
        "",
        "plainstring",
        "@example.com",
        "user@",
        "user@example",
        "user@.com",
        "user name@example.com",
        "user@example.c",
        " user@example.com"
    ])
    func rejectsInvalid(_ email: String) {
        #expect(!EmailValidator.isValid(email))
    }
}

// MARK: - FormValidation

@Suite("FormValidation")
struct FormValidationTests {

    private func validation(
        name: String = "",
        email: String = "",
        password: String = "",
        confirmPassword: String = ""
    ) -> FormValidation {
        FormValidation(name: name, email: email, password: password, confirmPassword: confirmPassword)
    }

    @Test("a name needs at least two letters")
    func nameRules() {
        #expect(!validation(name: "").isNameValid)
        #expect(!validation(name: "A").isNameValid)
        #expect(!validation(name: "12 34").isNameValid)
        #expect(validation(name: "Al").isNameValid)
        #expect(validation(name: "Нишад Зульфугарли").isNameValid)
    }

    @Test("password requirements are checked independently")
    func passwordRules() {
        let weak = validation(password: "abc")
        #expect(!weak.hasMinLength)
        #expect(!weak.hasUppercase)
        #expect(weak.hasLowercase)
        #expect(!weak.hasNumber)
        #expect(!weak.isPasswordValid)

        let strong = validation(password: "Password1")
        #expect(strong.hasMinLength)
        #expect(strong.hasUppercase)
        #expect(strong.hasLowercase)
        #expect(strong.hasNumber)
        #expect(strong.isPasswordValid)
    }

    @Test("eight characters alone is not enough")
    func lengthIsNotSufficient() {
        #expect(!validation(password: "password").isPasswordValid)   // no uppercase, no digit
        #expect(!validation(password: "PASSWORD1").isPasswordValid)  // no lowercase
        #expect(validation(password: "Pasword1").isPasswordValid)    // exactly 8, all rules met
    }

    @Test("confirmation must be non-empty and identical")
    func confirmationRules() {
        #expect(!validation(password: "Password1", confirmPassword: "").passwordsMatch)
        #expect(!validation(password: "Password1", confirmPassword: "Password2").passwordsMatch)
        #expect(validation(password: "Password1", confirmPassword: "Password1").passwordsMatch)
    }

    @Test("the form is valid only when every rule passes")
    func formValidity() {
        #expect(validation(
            email: "user@example.com",
            password: "Password1",
            confirmPassword: "Password1"
        ).isFormValid)

        #expect(!validation(
            email: "not-an-email",
            password: "Password1",
            confirmPassword: "Password1"
        ).isFormValid)

        #expect(!validation(
            email: "user@example.com",
            password: "weak",
            confirmPassword: "weak"
        ).isFormValid)

        #expect(!validation(
            email: "user@example.com",
            password: "Password1",
            confirmPassword: "Password2"
        ).isFormValid)
    }
}

// MARK: - TodoTask

@MainActor
@Suite("TodoTask")
struct TodoTaskTests {

    @Test("a task with no due date is never overdue")
    func noDueDate() {
        #expect(!makeTask(dueDate: nil).isOverdue)
    }

    @Test("a completed task is never overdue")
    func completedIsNotOverdue() {
        let task = makeTask(isCompleted: true, dueDate: Date().addingTimeInterval(-day))
        #expect(!task.isOverdue)
    }

    @Test("an unfinished task past its due date is overdue")
    func pastDueIsOverdue() {
        #expect(makeTask(dueDate: Date().addingTimeInterval(-hour)).isOverdue)
        #expect(!makeTask(dueDate: Date().addingTimeInterval(hour)).isOverdue)
    }
}

// MARK: - TaskBuckets

@MainActor
@Suite("TaskBuckets")
struct TaskBucketsTests {

    @Test("an unfinished task past its due date lands in Overdue")
    func overdue() {
        let task = makeTask(dueDate: offset(-hour))
        let buckets = TaskBuckets(tasks: [task], now: noon)

        #expect(buckets.overdue.map(\.id) == [task.id])
        #expect(buckets.todayActive.isEmpty)
    }

    @Test("a task due later today is active today, not upcoming")
    func todayActive() {
        let task = makeTask(dueDate: offset(hour))
        let buckets = TaskBuckets(tasks: [task], now: noon)

        #expect(buckets.todayActive.map(\.id) == [task.id])
        #expect(buckets.upcomingActive.isEmpty)
        #expect(buckets.overdue.isEmpty)
    }

    @Test("a task due on a later day is upcoming")
    func upcomingActive() {
        let task = makeTask(dueDate: offset(2 * day))
        let buckets = TaskBuckets(tasks: [task], now: noon)

        #expect(buckets.upcomingActive.map(\.id) == [task.id])
        #expect(buckets.todayActive.isEmpty)
    }

    @Test("completed tasks are split by completion day, past ones left for History")
    func completed() {
        let completedToday = makeTask(
            isCompleted: true, dueDate: offset(hour), completedAt: offset(-hour)
        )
        let completedEarlierButStillDue = makeTask(
            isCompleted: true, dueDate: offset(2 * day), completedAt: offset(-2 * day)
        )
        let completedLongAgo = makeTask(
            isCompleted: true, dueDate: offset(-3 * day), completedAt: offset(-3 * day)
        )

        let buckets = TaskBuckets(
            tasks: [completedToday, completedEarlierButStillDue, completedLongAgo],
            now: noon
        )

        #expect(buckets.todayCompleted.map(\.id) == [completedToday.id])
        #expect(buckets.upcomingCompleted.map(\.id) == [completedEarlierButStillDue.id])
        // Neither segment shows it — it belongs to History.
        #expect(buckets.overdue.isEmpty)
        #expect(!buckets.todayCompleted.contains { $0.id == completedLongAgo.id })
        #expect(!buckets.upcomingCompleted.contains { $0.id == completedLongAgo.id })
    }

    @Test("a task completed today but due earlier still shows under Today")
    func completedTodayButOverdue() {
        // Regression: keyed off the due date this fell through every bucket —
        // History only covers previous days — and disappeared from the UI.
        let task = makeTask(
            isCompleted: true, dueDate: offset(-4 * day), completedAt: offset(-hour)
        )

        let buckets = TaskBuckets(tasks: [task], now: noon)

        #expect(buckets.todayCompleted.map(\.id) == [task.id])
        #expect(buckets.overdue.isEmpty)
    }

    @Test("tasks without a due date are ignored entirely")
    func noDueDateIsSkipped() {
        let buckets = TaskBuckets(tasks: [makeTask(dueDate: nil)], now: noon)

        #expect(buckets.overdue.isEmpty)
        #expect(buckets.todayActive.isEmpty)
        #expect(buckets.todayCompleted.isEmpty)
        #expect(buckets.upcomingActive.isEmpty)
        #expect(buckets.upcomingCompleted.isEmpty)
    }

    @Test("active buckets are sorted by due date, soonest first")
    func activeSorting() {
        let later = makeTask(id: "later", dueDate: offset(5 * hour))
        let sooner = makeTask(id: "sooner", dueDate: offset(hour))

        let buckets = TaskBuckets(tasks: [later, sooner], now: noon)

        #expect(buckets.todayActive.map(\.id) == ["sooner", "later"])
    }

    @Test("completed buckets are sorted by completion time, most recent first")
    func completedSorting() {
        let earlier = makeTask(
            id: "earlier", isCompleted: true, dueDate: offset(hour), completedAt: offset(-5 * hour)
        )
        let recent = makeTask(
            id: "recent", isCompleted: true, dueDate: offset(hour), completedAt: offset(-hour)
        )

        let buckets = TaskBuckets(tasks: [earlier, recent], now: noon)

        #expect(buckets.todayCompleted.map(\.id) == ["recent", "earlier"])
    }
}

// MARK: - Date & Array helpers

@Suite("Helpers")
struct HelperTests {

    @Test("endOfDay keeps the day and moves the clock to 23:59:59")
    func endOfDay() {
        let end = noon.endOfDay
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: end)

        #expect(components.year == 2026)
        #expect(components.month == 6)
        #expect(components.day == 15)
        #expect(components.hour == 23)
        #expect(components.minute == 59)
        #expect(components.second == 59)
        #expect(end > noon)
    }

    @Test("chunked splits without losing or duplicating elements")
    func chunked() {
        let numbers = Array(1...10)

        #expect(numbers.chunked(into: 3).map(\.count) == [3, 3, 3, 1])
        #expect(numbers.chunked(into: 3).flatMap { $0 } == numbers)
        #expect(numbers.chunked(into: 20).map(\.count) == [10])
        #expect([Int]().chunked(into: 5).isEmpty)
    }

    @Test("chunked tolerates a non-positive size instead of trapping")
    func chunkedGuard() {
        #expect(Array(1...3).chunked(into: 0) == [[1, 2, 3]])
    }
}
