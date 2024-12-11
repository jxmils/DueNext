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
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGray6))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)

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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
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
