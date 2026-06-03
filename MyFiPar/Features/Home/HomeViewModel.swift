//
//  HomeViewModel.swift
//  MyFiPar
//

import Foundation
import SwiftData

@MainActor
@Observable
class HomeViewModel {

    func activeGoal(from goals: [Goal], in date: Date = .now, calendar: Calendar = .current) -> Goal? {
        guard let interval = calendar.dateInterval(of: .month, for: date) else { return nil }
        return goals.first { interval.contains($0.periodStart) }
    }

    func todaySpent(from transactions: [Transaction], on date: Date = .now, calendar: Calendar = .current) -> Decimal {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }
        return transactions.reduce(into: Decimal(0)) { total, transaction in
            guard transaction.category != .income,
                  transaction.date >= startOfDay,
                  transaction.date < endOfDay else { return }
            total += transaction.amount
        }
    }

    func recent(from transactions: [Transaction], limit: Int = 4) -> [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(limit))
    }

    /// Seeds a 2,000 placeholder goal for the current month if none exists yet.
    /// Replace with real goal entry UI before shipping.
    func ensurePlaceholderGoal(
        in context: ModelContext,
        existing goals: [Goal],
        for date: Date = .now,
        calendar: Calendar = .current
    ) {
        guard activeGoal(from: goals, in: date, calendar: calendar) == nil,
              let interval = calendar.dateInterval(of: .month, for: date) else { return }
        let placeholder = Goal(amount: 2_000, month: interval.start)
        context.insert(placeholder)
    }
}
