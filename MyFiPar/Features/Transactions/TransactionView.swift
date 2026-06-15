//
//  TransactionView.swift
//  MyFiPar
//
//  Created by Miller A on 5/22/26.
//

import SwiftUI
import SwiftData

struct TransactionView: View {
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var viewModel = TransactionViewModel()
    @State private var showingAddSheet = false
    @State private var selectedDate: Date? = nil
    @State private var displayedMonth: Date = .now
    @State private var viewMode: ViewMode = .daily

    enum ViewMode { case daily, monthly }

    private let calendar: Calendar = .current

    private var markedDates: Set<Date> {
        Set(transactions.map { calendar.startOfDay(for: $0.date) })
    }

    private var monthTitle: String {
        if viewMode == .monthly {
            let year = calendar.component(.year, from: displayedMonth)
            let currentYear = calendar.component(.year, from: .now)
            return year == currentYear ? "This Year" : "\(year)"
        }
        if calendar.isDate(displayedMonth, equalTo: .now, toGranularity: .month) {
            return "This Month"
        }
        let isSameYear = calendar.isDate(displayedMonth, equalTo: .now, toGranularity: .year)
        let format: Date.FormatStyle = isSameYear
            ? .dateTime.month(.wide)
            : .dateTime.month(.wide).year()
        return displayedMonth.formatted(format)
    }

    private var transactionsForSelectedDate: [Transaction] {
        guard let selectedDate else { return [] }
        return transactions
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date > $1.date }
    }

    private var transactionsForMonth: [Transaction] {
        transactions
            .filter { calendar.isDate($0.date, equalTo: displayedMonth, toGranularity: .month) }
            .sorted { $0.date > $1.date }
    }

    private var shouldShowAddButton: Bool {
        viewMode == .daily && selectedDate != nil
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TransactionsTopBar(
                    viewMode: $viewMode,
                    monthTitle: monthTitle,
                    showAddButton: shouldShowAddButton,
                    onShiftPeriod: shiftPeriod,
                    onAdd: { showingAddSheet = true }
                )
                .padding(.horizontal)

                MonthCalendarView(
                    selectedDate: $selectedDate,
                    displayedMonth: $displayedMonth,
                    markedDates: markedDates,
                    displayMode: viewMode == .daily ? .days : .months
                )
                .padding(.horizontal)

                switch viewMode {
                case .daily:
                    DailyExpensesSection(
                        selectedDate: selectedDate,
                        transactions: transactionsForSelectedDate,
                        onDelete: { viewModel.deleteTransaction(transaction: $0, context: context) }
                    )
                case .monthly:
                    MonthlyExpensesSection(
                        displayedMonth: displayedMonth,
                        transactions: transactionsForMonth,
                        onDelete: { viewModel.deleteTransaction(transaction: $0, context: context) }
                    )
                }
            }
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .sheet(isPresented: $showingAddSheet) {
                QuickAdd(initialDate: selectedDate ?? .now) { newTransaction in
                    viewModel.addTransaction(transaction: newTransaction, context: context)
                }
            }
            .alert("Couldn't add transaction", isPresented: $viewModel.hasError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func shiftPeriod(by value: Int) {
        let component: Calendar.Component = (viewMode == .monthly) ? .year : .month
        if let new = calendar.date(byAdding: component, value: value, to: displayedMonth) {
            displayedMonth = new
        }
    }
}
