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
    @State private var showingQuickAdd = false
    @State private var transactionViewModel = TransactionViewModel()

    enum Section: Hashable {
        case home
        case expenses
        case add
    }

    var body: some View {
        TabView(selection: tabSelection) {
            Tab("", systemImage: "house.fill", value: .home) {
                HomeView()
            }
            Tab("", systemImage: "plus", value: .add) {
                Color.clear
            }
            Tab("", systemImage: "list.bullet", value: .expenses) {
                TransactionView()
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAdd { newTransaction in
                transactionViewModel.addTransaction(transaction: newTransaction, context: context)
            }
        }
    }

    private var tabSelection: Binding<Section> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == .add {
                    showingQuickAdd = true
                } else {
                    selectedTab = newValue
                }
            }
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, Goal.self], inMemory: true)
}
