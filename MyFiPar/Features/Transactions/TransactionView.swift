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

    private var index: TransactionsIndex {
        TransactionsIndex(transactions, calendar: calendar)
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

    private func transactionsForSelectedDate(using index: TransactionsIndex) -> [Transaction] {
        guard let selectedDate else { return [] }
        return index.transactions(on: selectedDate)
    }

    private func transactionsForMonth(using index: TransactionsIndex) -> [Transaction] {
        index.transactions(inMonthOf: displayedMonth)
    }

    private var shouldShowAddButton: Bool {
        viewMode == .daily && selectedDate != nil
    }

    private var isAtCurrentPeriod: Bool {
        let granularity: Calendar.Component = (viewMode == .monthly) ? .year : .month
        return calendar.isDate(displayedMonth, equalTo: .now, toGranularity: granularity)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        let index = index

        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TransactionsTopBar(
                    viewMode: $viewMode,
                    monthTitle: monthTitle,
                    showAddButton: shouldShowAddButton,
                    isAtCurrentPeriod: isAtCurrentPeriod,
                    onShiftPeriod: shiftPeriod,
                    onResetToCurrent: resetToCurrentPeriod,
                    onAdd: { showingAddSheet = true }
                )
                .padding(.horizontal)

                MonthCalendarView(
                    selectedDate: $selectedDate,
                    displayedMonth: $displayedMonth,
                    markedDates: index.markedDays,
                    displayMode: viewMode == .daily ? .days : .months
                )
                .padding(.horizontal)

                switch viewMode {
                case .daily:
                    DailyExpensesSection(
                        selectedDate: selectedDate,
                        dayTransactions: transactionsForSelectedDate(using: index),
                        onDelete: { viewModel.deleteTransaction(transaction: $0, context: context) }
                    )
                case .monthly:
                    MonthlyExpensesSection(
                        displayedMonth: displayedMonth,
                        monthTransactions: transactionsForMonth(using: index),
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
            withAnimation(.easeInOut(duration: 0.25)) {
                displayedMonth = new
            }
        }
    }

    private func resetToCurrentPeriod() {
        withAnimation(.easeInOut(duration: 0.25)) {
            displayedMonth = .now
        }
    }
}
#Preview {
    TransactionView()
}
