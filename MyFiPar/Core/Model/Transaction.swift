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
    @Attribute(.unique) var id: UUID
    var amount: Double
    var category: TransactionCategory
    var date: Date
    var merchant: String
    
    init(id: UUID = UUID(), amount: Double, category: TransactionCategory, date: Date, merchant: String) {
        self.id = id
        self.amount = amount
        self.category = TransactionCategory(rawValue: category.rawValue)!
        self.date = date
        self.merchant = merchant
    }
}

protocol Updateable { }

extension NSObject: Updateable {}

extension Updateable where Self: NSObject {
    func update(completion: (Self) -> Void) {
        completion(self)
    }
}
