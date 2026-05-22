//
//  TransactionEntry.swift
//  MyFiPar
//
//  Created by Miller A on 5/21/26.
//
import SwiftUI
struct QuickAdd: View {
    
    @Environment(\.dismiss) private var dismiss
    var onsave: (Transaction) -> Void
    
    @State private var amount: Double = 0
    @State private var date: Date = Date()
    @State private var category: TransactionCategory = .other
    @State private var merchant: String
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Transaction")) {
                    TextField("Merchant", text: $merchant)
                    TextField("Amount", value: $amount, format: .number)
                    Picker("Category", selection: $category) {
                        ForEach(TransactionCategory.allCases, id: \.self){
                            category in Text(category.rawValue)
                        }
                    }
                }
                .navigationTitle(Text("Quick Add"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {dismiss()}
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let newTransaction = Transaction(
                                amount: amount,
                                category: category,
                                date: date,
                                merchant: "")
                            onsave(newTransaction)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
}
