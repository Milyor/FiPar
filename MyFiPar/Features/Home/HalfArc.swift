//
//  HalfArc.swift
//  MyFiPar
//

import SwiftUI

struct HalfArc: Shape {
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
