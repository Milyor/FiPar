//
//  BudgetGaugeView.swift
//  MyFiPar
//

import SwiftUI

struct BudgetGaugeView: View {
    var spent: Decimal
    var goal: Decimal

    private var progress: Double {
        guard goal > 0 else { return 0 }
        let spentValue = NSDecimalNumber(decimal: spent).doubleValue
        let goalValue = NSDecimalNumber(decimal: goal).doubleValue
        return min(max(spentValue / goalValue, 0), 1)
    }

    private var remaining: Decimal { max(goal - spent, 0) }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var arcGradient: AngularGradient {
        AngularGradient(
            colors: [.orange.opacity(0.85), .orange],
            center: .bottom,
            startAngle: .degrees(180),
            endAngle: .degrees(360)
        )
    }

    var body: some View {
        ZStack(alignment: .center) {
            HalfArc()
                .stroke(Color(.systemGray5),
                        style: StrokeStyle(lineWidth: 22, lineCap: .round))

            HalfArc()
                .trim(from: 0, to: progress)
                .stroke(arcGradient,
                        style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .animation(.smooth, value: progress)

            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(spent, format: .currency(code: currencyCode))
                    Text("SPENT")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Text(remaining, format: .currency(code: currencyCode))
                    Text("LEFT")
                }
                .font(.title2.bold())
                .foregroundStyle(.orange)

                HStack(spacing: 4) {
                    Text("of")
                    Text(goal, format: .currency(code: currencyCode))
                    Text("budget")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .offset(y: 10)
        }
        .aspectRatio(2, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Monthly budget")
        .accessibilityValue(
            "\(remaining.formatted(.currency(code: currencyCode))) remaining of \(goal.formatted(.currency(code: currencyCode)))"
        )
    }
}

private struct HalfArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width / 2, rect.height) - 12
        let center = CGPoint(x: rect.midX, y: rect.maxY - 12)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(360),
            clockwise: false
        )
        return path
    }
}

#Preview {
    VStack(spacing: 32) {
        BudgetGaugeView(spent: 1_346, goal: 2_000)
        BudgetGaugeView(spent: 250, goal: 2_000)
        BudgetGaugeView(spent: 0, goal: 0)
    }
    .padding()
}
