//
//  DayCell.swift
//  MyFiPar
//

import SwiftUI

struct DayCell: View {
    let day: Int
    let isSelected: Bool
    let isToday: Bool
    let hasMark: Bool

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if isSelected {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 1.5)
                        .frame(width: 30, height: 30)
                }
                Text("\(day)")
                    .font(.body)
                    .foregroundStyle(isToday ? Color.accentColor : .primary)
            }
            .frame(height: 30)

            Circle()
                .fill(Color.orange)
                .frame(width: 5, height: 5)
                .opacity(hasMark ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
    }
}
