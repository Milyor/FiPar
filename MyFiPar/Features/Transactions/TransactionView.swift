//
//  TransactionView.swift
//  MyFiPar
//
//  Created by Miller A on 5/22/26.
//

import SwiftUI
import SwiftData

struct TransactionView: View {
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var context
    @State private var viewModel = TransactionViewModel()
    @State private var showingAddSheet = false

    
    var body: some View {
        NavigationStack {
            List {
                ForEach(transactions) { transaction in
                    NavigationLink {
                        TransactionDetailView(transaction: transaction)
                    } label: {
                        TransactionRow(transaction: transaction)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteTransaction(
                            transaction: transactions[index],
                            context: context
                        )
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                QuickAdd{
                    newTransaction in viewModel.addTransaction(transaction: newTransaction, context: context)
                }
            }
            .navigationTitle(Text("Expenses"))
            .toolbar {
                Button("Add Transaction", systemImage: "plus") {
                    showingAddSheet.toggle()
                }
            }
        }
    }
}
