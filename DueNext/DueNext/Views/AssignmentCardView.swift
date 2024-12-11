//
//  AssignmentCardView.swift
//  DueNext
//
//  Created by Jason Miller on 11/5/24.
//
import SwiftUI

struct AssignmentCard: View {
    var assignment: Assignment
    @ObservedObject var viewModel: AssignmentViewModel
    @State private var timeRemaining: String = ""

    // Update time remaining
    private func updateTimeRemaining() {
        let interval = assignment.dueDate.timeIntervalSinceNow
        if interval > 0 {
            let hours = Int(interval) / 3600
            let minutes = Int(interval) % 3600 / 60
            timeRemaining = "\(hours)h \(minutes)m remaining"
        } else {
            timeRemaining = "Due Now"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(assignment.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(assignment.subject)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(timeRemaining)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .onAppear {
                        updateTimeRemaining()
                        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                            updateTimeRemaining()
                        }
                    }
            }
            Spacer()
            Text(assignment.dueDate, style: .time)
                .font(.caption)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(action: {
                viewModel.toggleCompletion(for: assignment)
            }) {
                Label("Complete", systemImage: "checkmark.circle")
            }
            .tint(.green)
        }
    }
}

struct SwipeableAssignmentCard: View {
    var assignment: Assignment
    @ObservedObject var viewModel: AssignmentViewModel
    @State private var offsetX: CGFloat = 0
    @State private var hapticsTriggered: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            // Background for swipe action
            HStack {
                Spacer()
                Color.green
                    .frame(width: -offsetX > 0 ? -offsetX : 0) // Dynamic width based on swipe
                    .overlay(
                        Label("Complete", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.white)
                            .opacity(-offsetX > 80 ? 1 : 0.5) // Fade in the label as you swipe
                    )
                    .cornerRadius(12)
                    .padding(.vertical, 4)
            }

            AssignmentCard(assignment: assignment, viewModel: viewModel)
                .offset(x: offsetX)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offsetX = value.translation.width
                                
                                // Trigger haptics when crossing the threshold
                                if !hapticsTriggered && value.translation.width < -80 {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    hapticsTriggered = true
                                }
                            }
                        }
                        .onEnded { value in
                            if value.translation.width < -80 {
                                withAnimation {
                                    viewModel.toggleCompletion(for: assignment)
                                    offsetX = 0 // Reset the position
                                }
                            } else {
                                withAnimation {
                                    offsetX = 0 // Snap back if not far enough
                                }
                            }
                            hapticsTriggered = false // Reset haptic trigger
                        }
                )
        }
    }
}
