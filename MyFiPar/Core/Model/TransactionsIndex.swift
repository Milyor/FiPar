//
//  TransactionsIndex.swift
//  MyFiPar
//

import Foundation

/// O(1) lookups by day or month, built once from the full transactions array.
/// `markedDays` is derived from `byDay.keys`, so calendar indicators can never
/// drift from the underlying data.
struct TransactionsIndex {
    let byDay: [Date: [Transaction]]
    let byMonth: [Date: [Transaction]]
    private let calendar: Calendar

    init(_ transactions: [Transaction], calendar: Calendar = .current) {
        self.calendar = calendar

        var byDay: [Date: [Transaction]] = [:]
        var byMonth: [Date: [Transaction]] = [:]

        for transaction in transactions {
            let day = calendar.startOfDay(for: transaction.date)
            byDay[day, default: []].append(transaction)

            if let monthInterval = calendar.dateInterval(of: .month, for: transaction.date) {
                byMonth[monthInterval.start, default: []].append(transaction)
            }
        }

        self.byDay = byDay.mapValues { $0.sorted { $0.date > $1.date } }
        self.byMonth = byMonth.mapValues { $0.sorted { $0.date > $1.date } }
    }

    var markedDays: Set<Date> { Set(byDay.keys) }

    func transactions(on date: Date) -> [Transaction] {
        byDay[calendar.startOfDay(for: date)] ?? []
    }

    func transactions(inMonthOf date: Date) -> [Transaction] {
        guard let interval = calendar.dateInterval(of: .month, for: date) else { return [] }
        return byMonth[interval.start] ?? []
    }

    func count(on date: Date) -> Int {
        byDay[calendar.startOfDay(for: date)]?.count ?? 0
    }
}
