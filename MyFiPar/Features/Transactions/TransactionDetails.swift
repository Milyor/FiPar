//
//  TransactionDetails.swift
//  MyFiPar
//
//  Created by Miller A on 5/22/26.
//

import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let transaction: Transaction
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(transaction.merchant ?? "Unassigned")
                .font(.body)
                .bold()
            
            Text(transaction.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.body)
                .bold()
                .foregroundStyle(Color.secondary)
            Text(transaction.category.rawValue)
                .font(.caption)
                .bold()
                .foregroundStyle(Color.secondary)
            
            Text(transaction.date, format: .dateTime.day().month().year())
                .font(.caption)
                .foregroundStyle(Color.gray)
            
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .navigationTitle("Details")
        .navigationBarBackButtonHidden(false)
    }
}
