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
            Text(transaction.merchant)
            Spacer()
            Text(transaction.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        }
        .padding(.vertical, 4)
    }
}
