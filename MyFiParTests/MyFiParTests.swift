//
//  MyFiParTests.swift
//  MyFiParTests
//
//  Created by Miller A on 5/21/26.
//

import Foundation
import Testing
import SwiftData
@testable import MyFiPar

@MainActor
struct TransactionViewModelTests {

    // Each test gets a fresh in-memory SwiftData context so nothing leaks
    // between tests and nothing touches disk.
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Transaction.self, Goal.self,
            configurations: config
        )
        return ModelContext(container)
    }

    // MARK: - addTransaction

    @Test
    func addTransactionInsertsIntoContext() throws {
        let context = try makeContext()
        let viewModel = TransactionViewModel()

        let transaction = Transaction(
            amount: 12.50,
            category: .food,
            date: Date(),
            merchant: "Coffee Shop"
        )

        viewModel.addTransaction(transaction: transaction, context: context)

        let stored = try context.fetch(FetchDescriptor<Transaction>())
        #expect(stored.count == 1)
        #expect(stored.first?.merchant == "Coffee Shop")
        #expect(stored.first?.amount == 12.50)
        #expect(stored.first?.category == .food)
        #expect(viewModel.errorMessage.isEmpty)
    }

    @Test
    func addTransactionRejectsSameDaySameAmountDuplicate() throws {
        let context = try makeContext()
        let viewModel = TransactionViewModel()
        let date = Date()

        let first = Transaction(amount: 9.99, category: .food, date: date, merchant: "Lunch")
        let duplicate = Transaction(amount: 9.99, category: .food, date: date, merchant: "Lunch")

        viewModel.addTransaction(transaction: first, context: context)
        viewModel.addTransaction(transaction: duplicate, context: context)

        let stored = try context.fetch(FetchDescriptor<Transaction>())
        #expect(stored.count == 1)
        #expect(viewModel.errorMessage == "Transaction already exists")
    }

    @Test
    func addTransactionAllowsSameAmountOnDifferentDays() throws {
        let context = try makeContext()
        let viewModel = TransactionViewModel()
        let today = Date()
        let yesterday = try #require(
            Calendar.current.date(byAdding: .day, value: -1, to: today)
        )

        viewModel.addTransaction(
            transaction: Transaction(amount: 5.00, category: .food, date: today, merchant: "A"),
            context: context
        )
        viewModel.addTransaction(
            transaction: Transaction(amount: 5.00, category: .food, date: yesterday, merchant: "B"),
            context: context
        )

        let stored = try context.fetch(FetchDescriptor<Transaction>())
        #expect(stored.count == 2)
    }

    @Test
    func addTransactionAllowsSameDayDifferentAmounts() throws {
        let context = try makeContext()
        let viewModel = TransactionViewModel()
        let date = Date()

        viewModel.addTransaction(
            transaction: Transaction(amount: 5.00, category: .food, date: date, merchant: "A"),
            context: context
        )
        viewModel.addTransaction(
            transaction: Transaction(amount: 7.50, category: .food, date: date, merchant: "B"),
            context: context
        )

        let stored = try context.fetch(FetchDescriptor<Transaction>())
        #expect(stored.count == 2)
    }

    // MARK: - deleteTransaction

    @Test
    func deleteTransactionRemovesIt() throws {
        let context = try makeContext()
        let viewModel = TransactionViewModel()

        let transaction = Transaction(
            amount: 10,
            category: .other,
            date: Date(),
            merchant: "Test"
        )
        viewModel.addTransaction(transaction: transaction, context: context)
        #expect(try context.fetch(FetchDescriptor<Transaction>()).count == 1)

        viewModel.deleteTransaction(transaction: transaction, context: context)

        let stored = try context.fetch(FetchDescriptor<Transaction>())
        #expect(stored.isEmpty)
    }

    // MARK: - filtered

    @Test
    func filteredReturnsAllWhenSearchTextIsEmpty() {
        let viewModel = TransactionViewModel()
        let transactions = [
            Transaction(amount: 1, category: .food, date: Date(), merchant: "Starbucks"),
            Transaction(amount: 2, category: .food, date: Date(), merchant: "Whole Foods")
        ]

        let result = viewModel.filtered(transactions: transactions)

        #expect(result.count == 2)
    }

    @Test
    func filteredMatchesMerchantCaseInsensitively() {
        let viewModel = TransactionViewModel()
        viewModel.searchText = "star"

        let transactions = [
            Transaction(amount: 1, category: .food, date: Date(), merchant: "Starbucks"),
            Transaction(amount: 2, category: .food, date: Date(), merchant: "Whole Foods")
        ]

        let result = viewModel.filtered(transactions: transactions)

        #expect(result.count == 1)
        #expect(result.first?.merchant == "Starbucks")
    }

    @Test
    func filteredReturnsEmptyWhenNoMerchantMatches() {
        let viewModel = TransactionViewModel()
        viewModel.searchText = "nothing-matches"

        let transactions = [
            Transaction(amount: 1, category: .food, date: Date(), merchant: "Starbucks")
        ]

        let result = viewModel.filtered(transactions: transactions)

        #expect(result.isEmpty)
    }
}
