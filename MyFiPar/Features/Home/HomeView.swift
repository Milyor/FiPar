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

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
        NavigationStack {
            TimelineView(MonthSchedule()) { context in
                content(referenceDate: context.date)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            
        }
        .task {
            viewModel.ensurePlaceholderGoal(in: modelContext, existing: goals)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scenePadding(.horizontal)
        .background(Color(.systemGroupedBackground))
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
                header(date: referenceDate, todayTotal: todayTotal)

                BudgetGaugeView(spent: monthSpent, goal: goalAmount)
                    .padding(.horizontal)

                focusCard(spent: monthSpent, goal: goalAmount)

                recentList(recent)
            }
            .padding(.vertical)
        }
    }

    private func header(date: Date, todayTotal: Decimal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(date, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Spent Today")
                .font(.headline)
            Text(todayTotal, format: .currency(code: currencyCode))
                .font(.largeTitle.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private func focusCard(spent: Decimal, goal: Decimal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your monthly focus")
                .font(.subheadline.bold())
            Text(focusMessage(spent: spent, goal: goal))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private func focusMessage(spent: Decimal, goal: Decimal) -> String {
        guard goal > 0 else {
            return "Set a monthly goal to start tracking your progress."
        }
        let remaining = goal - spent
        if remaining > 0 {
            let formatted = remaining.formatted(.currency(code: currencyCode))
            let goalFormatted = goal.formatted(.currency(code: currencyCode))
            return "You have \(formatted) left of your \(goalFormatted) monthly goal."
        } else {
            let over = (spent - goal).formatted(.currency(code: currencyCode))
            return "You're over your monthly goal by \(over). Time to slow down."
        }
    }

    @ViewBuilder
    private func recentList(_ recent: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last Expenses")
                .font(.headline)
                .padding(.horizontal)

            if recent.isEmpty {
                Text("No transactions yet. Add one to get started.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recent.enumerated()), id: \.element.id) { index, transaction in
                        NavigationLink {
                            TransactionDetailView(transaction: transaction)
                        } label: {
                            TransactionRow(transaction: transaction)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)

                        if index < recent.count - 1 {
                            Divider().padding(.leading)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Transaction.self, Goal.self], inMemory: true)
}
