//
//  Transaction.swift
//  MyFiPar
//
//  Created by Miller A on 5/21/26.
//

import SwiftUI
import SwiftData

@Model
class Transaction {
    var id: UUID = UUID()
    var amount: Decimal = 0.0
    var category: TransactionCat = TransactionCat.other
    var date: Date
    var merchant: String?
    
    init(id: UUID = UUID(), amount: Decimal, category: TransactionCat, date: Date, merchant: String) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.merchant = merchant
    }
}

