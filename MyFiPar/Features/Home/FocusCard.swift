//
//  FocusCard.swift
//  MyFiPar
//

import SwiftUI

struct FocusCard: View {
    let spent: Decimal
    let goal: Decimal

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var message: String {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your monthly focus")
                .font(.subheadline.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
