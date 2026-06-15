//
//  DailyExpensesSection.swift
//  MyFiPar
//

import SwiftUI

struct DailyExpensesSection: View {
    let selectedDate: Date?
    let dayTransactions: [Transaction]
    let onDelete: (Transaction) -> Void



    var body: some View {
        if selectedDate != nil {
            if dayTransactions.isEmpty {
                ContentUnavailableView(
                    "No expenses",
                    systemImage: "tray",
                    description: Text("Tap + to add an expense for this day.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(dayTransactions) { transaction in
                        NavigationLink(value: transaction) {
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            onDelete(dayTransactions[index])
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
