//
//  TransactionRow.swift
//  FinanceApp
//
//  Created by Miller A on 3/26/26.
//
import SwiftUI

struct TransactionRow: View {
    var transaction: Transaction
    var body: some View {
        HStack {
            Text(transaction.name)
            Spacer()
            Text(transaction.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        }
        .padding(.vertical, 4)
    }
}
