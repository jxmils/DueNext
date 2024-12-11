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

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header Section
                Text("Upcoming Assignments")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
                    .padding(.top)

                // Custom Scrollable Assignment List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Today Section
                        let todayAssignments = viewModel.filteredAssignments(for: .today)
                        if !todayAssignments.isEmpty {
                            AssignmentSection(title: "Today", assignments: todayAssignments, viewModel: viewModel)
                        }

                        // Tomorrow Section
                        let tomorrowAssignments = viewModel.filteredAssignments(for: .tomorrow)
                        if !tomorrowAssignments.isEmpty {
                            AssignmentSection(title: "Tomorrow", assignments: tomorrowAssignments, viewModel: viewModel)
                        }

                        // This Week Section
                        let weekAssignments = viewModel.filteredAssignments(for: .thisWeek)
                        if !weekAssignments.isEmpty {
                            AssignmentSection(title: "This Week", assignments: weekAssignments, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("DueNext")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: WorkloadView(viewModel: viewModel)) {
                            Image(systemName: "chart.pie.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isAddingNewAssignment = true
                        }) {
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
        }
    }
}

// Updated Assignment Section
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
                AssignmentCard(assignment: assignment, viewModel: viewModel)
            }
        }
        .padding(.bottom)
    }
}
