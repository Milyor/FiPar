//
//  TransactionCategory.swift
//  MyFiPar
//
//  Created by Miller A on 5/21/26.
//

enum TransactionCategory: String, Codable, CaseIterable {
    case housing = "Housing"
    case food = "Food"
    case transportation = "Transportation"
    case utilities = "Utilities"
    case healthcare = "Healthcare"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case education = "Education"
    case income = "Income"
    case other = "Other"
}
