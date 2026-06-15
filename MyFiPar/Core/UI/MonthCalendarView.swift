//
//  MonthCalendarView.swift
//  MyFiPar
//
//  A reusable month calendar with per-day indicators.
//  Decoupled from the data model: callers pass in a set of marked
//  start-of-day dates and bind to the selected date.
//

import SwiftUI

enum CalendarDisplayMode {
    case days
    case months
}

struct MonthCalendarView: View {
    @Binding var selectedDate: Date?
    @Binding var displayedMonth: Date
    var markedDates: Set<Date>
    var displayMode: CalendarDisplayMode = .days

    @State private var dragOffset: CGFloat = 0

    private let calendar: Calendar = .current
    private let dayColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let monthColumns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    private let swipeThreshold: CGFloat = 60

    var body: some View {
        VStack(spacing: 12) {
            Group {
                switch displayMode {
                case .days:
                    VStack(spacing: 12) {
                        weekdayRow
                        daysGrid
                    }
                case .months:
                    monthsGrid
                }
            }
            .offset(x: dragOffset)
            .gesture(swipeGesture)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                dragOffset = value.translation.width * 0.4
            }
            .onEnded { value in
                if value.translation.width < -swipeThreshold {
                    shiftPeriod(by: 1)
                } else if value.translation.width > swipeThreshold {
                    shiftPeriod(by: -1)
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    dragOffset = 0
                }
            }
    }

    private func shiftPeriod(by value: Int) {
        let component: Calendar.Component = (displayMode == .months) ? .year : .month
        if let new = calendar.date(byAdding: component, value: value, to: displayedMonth) {
            withAnimation(.easeInOut(duration: 0.25)) {
                displayedMonth = new
            }
        }
    }

    private var weekdayRow: some View {
        HStack(spacing: 4) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        LazyVGrid(columns: dayColumns, spacing: 6) {
            ForEach(monthCells.indices, id: \.self) { index in
                if let date = monthCells[index] {
                    Button {
                        selectedDate = date
                    } label: {
                        DayCell(
                            day: calendar.component(.day, from: date),
                            isSelected: selectedDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false,
                            isToday: calendar.isDateInToday(date),
                            hasMark: markedDates.contains(calendar.startOfDay(for: date))
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(date, format: .dateTime.weekday(.wide).month(.wide).day()))
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }

    private var monthsGrid: some View {
        LazyVGrid(columns: monthColumns, spacing: 12) {
            ForEach(monthOptions, id: \.self) { monthDate in
                Button {
                    displayedMonth = monthDate
                } label: {
                    MonthCell(
                        title: monthSymbol(for: monthDate),
                        isSelected: calendar.isDate(monthDate, equalTo: displayedMonth, toGranularity: .month),
                        isCurrent: calendar.isDate(monthDate, equalTo: .now, toGranularity: .month),
                        hasMark: markedMonths.contains(calendar.component(.month, from: monthDate))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(monthDate, format: .dateTime.month(.wide).year()))
            }
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return (Array(symbols[first...]) + Array(symbols[..<first])).map { $0.uppercased() }
    }

    private var monthCells: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }
        let firstOfMonth = monthInterval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 0
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for offset in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: offset, to: firstOfMonth) {
                cells.append(date)
            }
        }
        return cells
    }

    private var monthOptions: [Date] {
        let year = calendar.component(.year, from: displayedMonth)
        return (1...12).compactMap { month in
            calendar.date(from: DateComponents(year: year, month: month, day: 1))
        }
    }

    private var markedMonths: Set<Int> {
        let year = calendar.component(.year, from: displayedMonth)
        return Set(markedDates.compactMap { date in
            guard calendar.component(.year, from: date) == year else { return nil }
            return calendar.component(.month, from: date)
        })
    }

    private func monthSymbol(for date: Date) -> String {
        let index = calendar.component(.month, from: date) - 1
        let symbols = calendar.shortMonthSymbols
        guard symbols.indices.contains(index) else { return "" }
        return symbols[index].uppercased()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: Date? = nil
        @State private var displayedMonth: Date = .now
        @State private var mode: CalendarDisplayMode = .days
        var body: some View {
            VStack {
                Picker("Mode", selection: $mode) {
                    Text("Days").tag(CalendarDisplayMode.days)
                    Text("Months").tag(CalendarDisplayMode.months)
                }
                .pickerStyle(.segmented)
                MonthCalendarView(
                    selectedDate: $selected,
                    displayedMonth: $displayedMonth,
                    markedDates: Set([0, 2, 7, 8, 14, 15, 16, 17, 45, 80].compactMap {
                        Calendar.current.date(byAdding: .day, value: $0, to: Calendar.current.startOfDay(for: .now))
                    }),
                    displayMode: mode
                )
            }
            .padding()
        }
    }
    return PreviewWrapper()
}
