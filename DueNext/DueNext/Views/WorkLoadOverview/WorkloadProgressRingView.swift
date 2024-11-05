//
//  WorkloadProgressRingView.swift
//  DueNext
//
//  Created by Jason Miller on 11/5/24.
//

import SwiftUI

struct WorkloadProgressRing: View {
    var completionPercentage: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.gray)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(completionPercentage / 100, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(completionPercentage >= 100 ? .green : .blue)
                .rotationEffect(Angle(degrees: 270))
                .animation(.easeOut(duration: 1.5), value: completionPercentage)

            Text(String(format: "%.0f%%", min(completionPercentage, 100.0)))
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
        }
    }
}
