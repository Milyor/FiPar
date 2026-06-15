//
//  DailyExpensesSection.swift
//  MyFiPar
//

import SwiftUI

struct DailyExpensesSection: View {
    let selectedDate: Date?
    let transactions: [Transaction]
    let onDelete: (Transaction) -> Void

    private var dayHeader: String {
        guard let selectedDate else { return "" }
        return "\(selectedDate.formatted(.dateTime.day(.ordinalOfDayInMonth))) Expenses"
    }

    var body: some View {
        if selectedDate != nil {
            Text(dayHeader)
                .font(.title3.bold())
                .padding(.horizontal)

            if transactions.isEmpty {
                ContentUnavailableView(
                    "No expenses",
                    systemImage: "tray",
                    description: Text("Tap + to add an expense for this day.")
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
        } else {
            ContentUnavailableView(
                "Select a date",
                systemImage: "calendar",
                description: Text("Tap a date in the calendar to view its expenses.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
