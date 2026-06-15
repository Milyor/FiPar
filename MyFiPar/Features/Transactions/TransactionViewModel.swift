//
//  TransactionViewModel.swift
//  MyFiPar
//
//  Created by Miller A on 5/22/26.
//
import Foundation
import SwiftData

@MainActor
@Observable
class TransactionViewModel {

    var searchText: String = ""
    var errorMessage: String?

    var hasError: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    func addTransaction(transaction: Transaction, context: ModelContext) {
        let startOfDay = Calendar.current.startOfDay(for: transaction.date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        let amount = transaction.amount
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> {
                $0.amount == amount &&
                $0.date > startOfDay &&
                $0.date < endOfDay
            }
        )
        descriptor.fetchLimit = 5

        do {
            let existing = try context.fetch(descriptor)
            if !existing.isEmpty {
                errorMessage = "A transaction with that amount already exists for this day."
                return
            }
            context.insert(transaction)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTransaction(transaction: Transaction, context: ModelContext) {
        context.delete(transaction)
    }

    func filtered(transactions: [Transaction]) -> [Transaction] {
        guard !searchText.isEmpty else { return transactions }
        return transactions.filter {
            ($0.merchant ?? "").localizedStandardContains(searchText)
        }
    }
}
