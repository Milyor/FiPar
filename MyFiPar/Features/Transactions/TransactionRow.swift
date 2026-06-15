//
//  TransactionRow.swift
//  FiPar
//
//  Created by Miller A on 5/26/26.
//
import SwiftUI

struct TransactionRow: View {
    var transaction: Transaction
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.merchant ?? "Unassigned")
                Text(transaction.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(transaction.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        }
        .padding(.vertical, 4)
    }
}
