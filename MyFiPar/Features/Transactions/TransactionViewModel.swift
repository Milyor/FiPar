//
//  TransactionViewModel.swift
//  FinanceApp
//
//  Created by Miller A on 3/26/26.
//
import Foundation
import SwiftData

@MainActor
@Observable
class TransactionViewModel {
    
    var searchText: String = ""
    var errorMessage: String = ""
    
    func filtered(transaction: [Transaction]) -> [Transaction] {
        if searchText.isEmpty {
            return transaction
        } else {
            return transaction.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.category.rawValue == searchText}
        }
    }
    
    func addTransaction(transaction: Transaction, context: ModelContext) {

        let startOfDay = Calendar.current.startOfDay(for: transaction.date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {return}
        let name = transaction.name
        let amount = transaction.amount
        
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> {
                $0.name == name &&
                $0.amount == amount &&
                $0.date > startOfDay &&
                $0.date < endOfDay
            }
        )
        
        descriptor.fetchLimit = 5
        
        do {
            let existingTransaction = try context.fetch(descriptor)
            
            if !existingTransaction.isEmpty {
                    errorMessage = "Transaction already exists"
                     print(errorMessage)
                     return
                    }
            context.insert(transaction)
        } catch {
            errorMessage = String(error.localizedDescription)
            print(errorMessage)
            }
        
    }
    
    func deleteTransaction(transaction: Transaction, context: ModelContext) {
        context.delete(transaction)
    }
        

}
