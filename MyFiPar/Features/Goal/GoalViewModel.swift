//
//  GoalViewModel.swift
//  MyFiPar
//

import Foundation
import SwiftData

@MainActor
@Observable
class GoalViewModel {

    var errorMessage: String?

    var hasError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    func activeGoal(from goals: [Goal], in date: Date = .now, calendar: Calendar = .current) -> Goal? {
        guard let interval = calendar.dateInterval(of: .month, for: date) else { return nil }
        return goals.first { interval.contains($0.periodStart) }
    }

    func history(from goals: [Goal], excluding active: Goal?) -> [Goal] {
        goals
            .filter { $0.id != active?.id }
            .sorted { $0.periodStart > $1.periodStart }
    }

    /// Creates or updates the monthly goal for the month containing `date`.
    /// Returns the goal that was created or updated.
    @discardableResult
    func upsertGoal(
        amount: Decimal,
        for date: Date = .now,
        in context: ModelContext,
        existing goals: [Goal],
        calendar: Calendar = .current
    ) -> Goal? {
        guard amount >= 0 else {
            errorMessage = "Goal amount must be zero or greater."
            return nil
        }
        guard let interval = calendar.dateInterval(of: .month, for: date) else {
            errorMessage = "Could not resolve the current month."
            return nil
        }
        if let goal = activeGoal(from: goals, in: date, calendar: calendar) {
            goal.setAmount(amount)
            return goal
        }
        let goal = Goal(amount: amount, month: interval.start)
        context.insert(goal)
        return goal
    }
}
