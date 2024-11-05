//
//  AssignmentCardView.swift
//  DueNext
//
//  Created by Jason Miller on 11/5/24.
//

import SwiftUI

struct AssignmentCard: View {
    var assignment: Assignment
    @State private var isTapped = false
    @State private var timeRemaining: String = ""
    
    // Dynamic color based on due date
    private var accentColor: Color {
        let timeRemainingInterval = assignment.dueDate.timeIntervalSinceNow
        if timeRemainingInterval < 86400 { // Due within 1 day
            return Color.red
        } else if timeRemainingInterval < 604800 { // Due within 1 week
            return Color.orange
        } else {
            return Color.blue
        }
    }

    // Update time remaining
    private func updateTimeRemaining() {
        let interval = assignment.dueDate.timeIntervalSince(Date())
        if interval > 0 {
            let hours = Int(interval) / 3600
            let minutes = Int(interval) % 3600 / 60
            timeRemaining = "\(hours)h \(minutes)m remaining"
        } else {
            timeRemaining = "Due Now"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(assignment.title)
                .font(.headline)
                .bold()
                .lineLimit(1)
            
            Text(timeRemaining)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .onAppear {
                    updateTimeRemaining()
                    // Timer to update countdown every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        updateTimeRemaining()
                    }
                }
        }
        .padding()
        .background(
            VisualEffectBlur(blurStyle: .systemMaterial) // Glassmorphism effect
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.3), lineWidth: 1))
        )
        .background(
            LinearGradient(
                gradient: Gradient(colors: [accentColor.opacity(0.2), accentColor.opacity(0.5)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .scaleEffect(isTapped ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isTapped.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isTapped.toggle()
                }
            }
        }
    }
}
