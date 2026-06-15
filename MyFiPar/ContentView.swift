//
//  ContentView.swift
//  MyFiPar
//
//  Created by Miller A on 5/21/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var selectedTab: Section = .home
    @State private var previousTab: Section = .home
    @State private var showingQuickAdd = false
    @State private var transactionViewModel = TransactionViewModel()

    enum Section: Hashable {
        case home
        case expenses
        case add
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                HomeView()
            }
            Tab("Add", systemImage: "plus", value: .add) {
                Color.clear
            }
            Tab("Expenses", systemImage: "list.bullet", value: .expenses) {
                TransactionView()
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .add {
                showingQuickAdd = true
                selectedTab = oldValue
            } else {
                previousTab = newValue
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAdd { newTransaction in
                transactionViewModel.addTransaction(transaction: newTransaction, context: context)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, Goal.self], inMemory: true)
}
