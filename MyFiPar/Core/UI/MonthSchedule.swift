//
//  MonthSchedule.swift
//  MyFiPar
//
//  A TimelineSchedule that fires at the start of each calendar month,
//  so views wrapped in `TimelineView(MonthSchedule())` automatically
//  re-render when the month rolls over.
//

import SwiftUI

struct MonthSchedule: TimelineSchedule {
    var calendar: Calendar = .current

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        let calendar = calendar
        var current: Date? = startDate
        let firstOfMonth = DateComponents(day: 1, hour: 0, minute: 0, second: 0)

        return AnyIterator {
            guard let value = current else { return nil }
            current = calendar.nextDate(
                after: value,
                matching: firstOfMonth,
                matchingPolicy: .nextTime
            )
            return value
        }
    }
}
