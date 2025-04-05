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
        ZStack {
            // Background view
            if offsetX > 0 {
                // Right swipe: Delete action
                HStack {
                    Color.red
                        .frame(width: offsetX)
                        .overlay(
                            Label("Delete", systemImage: "trash")
                                .font(.caption)
                                .foregroundColor(.white)
                                .opacity(offsetX > 80 ? 1 : 0.5)
                        )
                    Spacer()
                }
            } else if offsetX < 0 {
                // Left swipe: Complete action
                HStack {
                    Spacer()
                    Color.green
                        .frame(width: -offsetX)
                        .overlay(
                            Label("Complete", systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(.white)
                                .opacity(-offsetX > 80 ? 1 : 0.5)
                        )
                }
            }
            
            // Foreground: the assignment card
            AssignmentCard(assignment: assignment, viewModel: viewModel)
                .offset(x: offsetX)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update offset for both directions
                            offsetX = value.translation.width
                            
                            // Trigger haptics when crossing threshold in either direction
                            if (abs(value.translation.width) > 80) && !hapticsTriggered {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                hapticsTriggered = true
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                if value.translation.width < -80 {
                                    // Left swipe: Complete action
                                    viewModel.toggleCompletion(for: assignment)
                                } else if value.translation.width > 80 {
                                    // Right swipe: Delete action
                                    viewModel.delete(assignment)
                                }
                                // Reset offset
                                offsetX = 0
                            }
                            hapticsTriggered = false
                        }
                )
        }
    }
}
