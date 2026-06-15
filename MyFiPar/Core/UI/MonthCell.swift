//
//  MonthCell.swift
//  MyFiPar
//

import SwiftUI

struct MonthCell: View {
    let title: String
    let isSelected: Bool
    let isCurrent: Bool
    let hasMark: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isCurrent ? Color.accentColor : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: isSelected ? 1.5 : 0)
                )

            Circle()
                .fill(Color.orange)
                .frame(width: 5, height: 5)
                .opacity(hasMark ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
    }
}
