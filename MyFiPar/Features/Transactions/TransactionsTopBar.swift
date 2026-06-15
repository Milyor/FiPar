//
//  TransactionsTopBar.swift
//  MyFiPar
//

import SwiftUI

struct TransactionsTopBar: View {
    @Binding var viewMode: TransactionView.ViewMode
    let monthTitle: String
    let showAddButton: Bool
    let isAtCurrentPeriod: Bool
    let onShiftPeriod: (Int) -> Void
    let onResetToCurrent: () -> Void
    let onAdd: () -> Void

    private let swipeThreshold: CGFloat = 60

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                if value.translation.width < -swipeThreshold {
                    onShiftPeriod(1)
                } else if value.translation.width > swipeThreshold {
                    onShiftPeriod(-1)
                }
            }
    }

    var body: some View {
        HStack {
            Button("Toggle calendar view", systemImage: "calendar") {
                viewMode = (viewMode == .daily) ? .monthly : .daily
            }
            .labelStyle(.iconOnly)
            .font(.title3)
            .foregroundStyle(viewMode == .monthly ? Color.accentColor : .secondary)
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 12) {
                Button("Previous period", systemImage: "chevron.left") {
                    onShiftPeriod(-1)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)

                Button {
                    if !isAtCurrentPeriod {
                        onResetToCurrent()
                    }
                } label: {
                    Text(monthTitle)
                        .font(.headline)
                        .underline()
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .disabled(isAtCurrentPeriod)

                Button("Next period", systemImage: "chevron.right") {
                    onShiftPeriod(1)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
            }

            Spacer()

            if showAddButton {
                Button("Add expense", systemImage: "plus.circle.fill", action: onAdd)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 30, height: 30)
            }
        }
        .contentShape(.rect)
        .simultaneousGesture(swipeGesture)
    }
}
