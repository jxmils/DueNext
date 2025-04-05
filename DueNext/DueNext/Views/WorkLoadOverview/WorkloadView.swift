//
//  WorkloadView.swift
//  DueNext
//
//  Created by Jason Miller on 11/5/24.
//

import SwiftUI

struct WorkloadView: View {
    @ObservedObject var viewModel: AssignmentViewModel

    var body: some View {
        ZStack {
            // Background fills the entire screen.
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // Content stays within safe area.
            VStack(spacing: 30) {
                Text("Weekly Workload Overview")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top)  // You can adjust this if needed

                // Weekly Progress Ring
                WorkloadProgressRing(completionPercentage: viewModel.weeklyCompletionPercentage)
                    .frame(width: 150, height: 150)

                // Weekly Assignment Summary
                VStack(spacing: 20) {
                    AssignmentSummaryCard(title: "Total Assignments", count: viewModel.weeklyAssignmentsCount, color: .blue)
                    AssignmentSummaryCard(title: "Completed Assignments", count: viewModel.weeklyCompletedAssignmentsCount, color: .green)
                    AssignmentSummaryCard(title: "On Time", count: viewModel.weeklyCompletedOnTimeCount, color: .purple)
                }
                .padding(.horizontal)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
