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
                
                List {
                    // Today Section
                    let todayAssignments = viewModel.filteredAssignments(for: .today)
                    if !todayAssignments.isEmpty {
                        AssignmentSection(title: "Today", assignments: todayAssignments)
                    }
                    
                    // Tomorrow Section
                    let tomorrowAssignments = viewModel.filteredAssignments(for: .tomorrow)
                    if !tomorrowAssignments.isEmpty {
                        AssignmentSection(title: "Tomorrow", assignments: tomorrowAssignments)
                    }
                    
                    // This Week Section
                    let weekAssignments = viewModel.filteredAssignments(for: .thisWeek)
                    if !weekAssignments.isEmpty {
                        AssignmentSection(title: "This Week", assignments: weekAssignments)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("DueNext")
                .toolbar {
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


// Assignment Section
struct AssignmentSection: View {
    var title: String
    var assignments: [Assignment]
    
    var body: some View {
        Section(header: Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)) {
            ForEach(assignments) { assignment in
                AssignmentCard(assignment: assignment)
                    .padding(.vertical, 4)
            }
        }
    }
}

// Assignment Card View
struct AssignmentCard: View {
    var assignment: Assignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(assignment.title)
                .font(.headline)
                .bold()
                .lineLimit(1)
                .padding(.bottom, 4)
            
            HStack {
                Text("Due \(assignment.dueDate, style: .time)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}
