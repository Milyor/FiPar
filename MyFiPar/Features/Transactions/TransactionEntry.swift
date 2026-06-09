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
    
    @State private var amount: Decimal? = nil
    @State private var date: Date = Date()
    @State private var category: TransactionCat = .other
    @State private var merchant: String = ""
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Expense")) {
                    TextField("Merchant", text: $merchant)
                    TextField("$", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                    Picker("Category", selection: $category) {
                        ForEach(TransactionCat.allCases, id: \.self){
                            category in Text(category.rawValue)
                        }
                    }
                }
            } .navigationTitle(Text("Quick Add"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {dismiss()}
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let newTransaction = Transaction(
                                amount: amount ?? 0,
                                category: category,
                                date: date,
                                merchant: merchant)
                            onsave(newTransaction)
                            dismiss()
                        }
                    }
                }
        }
    }
    
}
