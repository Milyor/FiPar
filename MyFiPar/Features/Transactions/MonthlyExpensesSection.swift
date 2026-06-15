//
//  MonthlyExpensesSection.swift
//  MyFiPar
//

import SwiftUI

struct MonthlyExpensesSection: View {
    let displayedMonth: Date
    let transactions: [Transaction]
    let onDelete: (Transaction) -> Void

    private var monthDisplayName: String {
        let isSameYear = Calendar.current.isDate(displayedMonth, equalTo: .now, toGranularity: .year)
        let format: Date.FormatStyle = isSameYear
            ? .dateTime.month(.wide)
            : .dateTime.month(.wide).year()
        return displayedMonth.formatted(format)
    }

    var body: some View {
        Text("\(monthDisplayName) Expenses")
            .font(.title3.bold())
            .padding(.horizontal)

        if transactions.isEmpty {
            ContentUnavailableView(
                "No expenses",
                systemImage: "tray",
                description: Text("No expenses recorded for this month.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(transactions) { transaction in
                    NavigationLink(value: transaction) {
                        TransactionRow(transaction: transaction)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        onDelete(transactions[index])
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
