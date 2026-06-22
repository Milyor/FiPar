//
//  GoalSettingsView.swift
//  MyFiPar
//

import SwiftUI
import SwiftData

struct GoalSettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Goal.periodStart, order: .reverse) private var goals: [Goal]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var viewModel = GoalViewModel()
    @State private var amount: Decimal?
    @State private var didPrefill = false

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var activeGoal: Goal? { viewModel.activeGoal(from: goals) }
    private var pastGoals: [Goal] { viewModel.history(from: goals, excluding: activeGoal) }

    private var isAmountValid: Bool {
        guard let amount else { return false }
        return amount >= 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Month") {
                        Text(Date.now, format: .dateTime.month(.wide).year())
                            .foregroundStyle(.secondary)
                    }
                    TextField(
                        "Monthly goal",
                        value: $amount,
                        format: .currency(code: currencyCode)
                    )
                    .keyboardType(.decimalPad)
                } header: {
                    Text("This Month")
                } footer: {
                    if let activeGoal {
                        let spent = activeGoal.spent(from: transactions)
                        let remaining = activeGoal.remaining(from: transactions)
                        Text(
                            "Spent \(spent.formatted(.currency(code: currencyCode))) · "
                            + "Remaining \(remaining.formatted(.currency(code: currencyCode)))"
                        )
                    } else {
                        Text("Set a goal to start tracking this month's progress.")
                    }
                }

                if !pastGoals.isEmpty {
                    Section("History") {
                        ForEach(pastGoals) { goal in
                            LabeledContent {
                                Text(goal.amount, format: .currency(code: currencyCode))
                                    .foregroundStyle(.secondary)
                            } label: {
                                Text(goal.periodStart, format: .dateTime.month(.wide).year())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Monthly Goal")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!isAmountValid)
                }
            }
            .alert("Error", isPresented: $viewModel.hasError) {
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear(perform: prefillIfNeeded)
    }

    private func cancel() {
        dismiss()
    }

    private func save() {
        guard let amount else { return }
        viewModel.upsertGoal(amount: amount, in: context, existing: goals)
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }

    private func prefillIfNeeded() {
        guard !didPrefill else { return }
        didPrefill = true
        amount = activeGoal?.amount
    }
}

#Preview {
    GoalSettingsView()
        .modelContainer(for: [Transaction.self, Goal.self], inMemory: true)
}
