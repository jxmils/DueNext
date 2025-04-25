//
//  MainView.swift
//  DueNext
//
//  Created by Jason Miller on 11/4/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = AssignmentViewModel()
    @State private var isAddingNewAssignment = false

    // Computed lists
    private var incompleteAssignments: [Assignment] {
        viewModel.assignments.filter { !$0.isCompleted }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header Section
                Text("DueNext Dashboard")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                // Placeholder or content
                ZStack {
                    // 1️⃣ Never added any assignments
                    if viewModel.assignments.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.3))

                            Text("No tasks added yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)

                            Text("Tap the + sign to get started!")
                                .font(.body)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // 2️⃣ All tasks completed
                    } else if incompleteAssignments.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green.opacity(0.7))

                            Text("All done for now!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)

                            Text("Great job! Tap + to add more.")
                                .font(.body)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // 3️⃣ Show the actual assignment sections
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // Today Section
                                let todayAssignments = viewModel.filteredAssignments(for: .today)
                                if !todayAssignments.isEmpty {
                                    AssignmentSection(
                                        title: "Today",
                                        assignments: todayAssignments,
                                        viewModel: viewModel
                                    )
                                }

                                // Tomorrow Section
                                let tomorrowAssignments = viewModel.filteredAssignments(for: .tomorrow)
                                if !tomorrowAssignments.isEmpty {
                                    AssignmentSection(
                                        title: "Tomorrow",
                                        assignments: tomorrowAssignments,
                                        viewModel: viewModel
                                    )
                                }

                                // This Week Section
                                let weekAssignments = viewModel.filteredAssignments(for: .thisWeek)
                                if !weekAssignments.isEmpty {
                                    AssignmentSection(
                                        title: "This Week",
                                        assignments: weekAssignments,
                                        viewModel: viewModel
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: WorkloadView(viewModel: viewModel)) {
                            Image(systemName: "chart.pie.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isAddingNewAssignment = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                    }
                }
                .sheet(isPresented: $isAddingNewAssignment) {
                    AddAssignmentView(viewModel: viewModel)
                }
                .onAppear {
                    viewModel.loadAssignments()
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - AssignmentSection

struct AssignmentSection: View {
    var title: String
    var assignments: [Assignment]
    @ObservedObject var viewModel: AssignmentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .bold()
                .padding(.leading)

            ForEach(assignments) { assignment in
                SwipeableAssignmentCard(assignment: assignment, viewModel: viewModel)
            }
        }
        .padding(.bottom)
    }
}
