//
//  Goal.swift
//  MyFiPar
//
//  Created by Miller A on 5/22/26.
//
import SwiftUI
import SwiftData

@Model
class Goal {
    var id: UUID = UUID()
    var amount: Decimal = 0.0
    var periodStart: Date
    
    
    init(id: UUID = UUID(), amount: Decimal, month: Date) {
        self.id = id
        self.amount = amount
        self.periodStart = month
    }

    func setAmount(_ newAmount: Decimal) {
        amount = newAmount
    }

    func spent(from transactions: [Transaction], in month: Date = .now, calendar: Calendar = .current) -> Decimal {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return 0 }
        return transactions.reduce(into: Decimal(0)) { total, transaction in
            guard transaction.category != .income,
                  interval.contains(transaction.date) else { return }
            total += transaction.amount
        }
    }

    func remaining(from transactions: [Transaction], in month: Date = .now, calendar: Calendar = .current) -> Decimal {
        amount - spent(from: transactions, in: month, calendar: calendar)
    }

    func progress(from transactions: [Transaction], in month: Date = .now, calendar: Calendar = .current) -> Double {
        guard amount > 0 else { return 0 }
        let spentValue = NSDecimalNumber(decimal: spent(from: transactions, in: month, calendar: calendar)).doubleValue
        let goalValue = NSDecimalNumber(decimal: amount).doubleValue
        return min(max(spentValue / goalValue, 0), 1)
    }
}
