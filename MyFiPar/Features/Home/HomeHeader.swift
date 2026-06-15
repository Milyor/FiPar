//
//  HomeHeader.swift
//  MyFiPar
//

import SwiftUI

struct HomeHeader: View {
    let date: Date
    let todayTotal: Decimal

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    var body: some View {
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
}
