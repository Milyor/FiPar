//
//  RecentTransactionsList.swift
//  MyFiPar
//

import SwiftUI

struct RecentTransactionsList: View {
    let transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Expenses")
                .font(.headline)
                .padding(.horizontal)

            if transactions.isEmpty {
                emptyState
            } else {
                list
            }
        }
    }

    private var emptyState: some View {
        Text("No transactions yet. Add one to get started.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal)
    }

    private var list: some View {
        VStack(spacing: 0) {
            ForEach(transactions.enumerated(), id: \.element.id) { index, transaction in
                NavigationLink(value: transaction) {
                    TransactionRow(transaction: transaction)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)

                if index < transactions.count - 1 {
                    Divider().padding(.leading)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal)
    }
}
