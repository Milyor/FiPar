//
//  HomeView.swift
//  MyFiPar
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var goals: [Goal]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var isShowingGoalSettings = false

    var body: some View {
        NavigationStack {
            TimelineView(MonthSchedule()) { context in
                content(referenceDate: context.date)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Monthly Goal", systemImage: "target") {
                        isShowingGoalSettings = true
                    }
                }
            }
            .sheet(isPresented: $isShowingGoalSettings) {
                GoalSettingsView()
            }
        }
        .task {
            viewModel.ensurePlaceholderGoal(in: modelContext, existing: goals)
        }
    }

    @ViewBuilder
    private func content(referenceDate: Date) -> some View {
        let goal = viewModel.activeGoal(from: goals, in: referenceDate)
        let todayTotal = viewModel.todaySpent(from: transactions, on: referenceDate)
        let monthSpent = goal?.spent(from: transactions, in: referenceDate) ?? 0
        let goalAmount = goal?.amount ?? 0
        let recent = viewModel.recent(from: transactions)

        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                HomeHeader(date: referenceDate, todayTotal: todayTotal)

                BudgetGaugeView(spent: monthSpent, goal: goalAmount)
                    .padding(.horizontal)

                FocusCard(spent: monthSpent, goal: goalAmount)

                RecentTransactionsList(transactions: recent)
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Transaction.self, Goal.self], inMemory: true)
}
