//
//  AssignmentRowView.swift
//  DueNext
//
//  Created by Jason Miller on 11/4/24.
//

import SwiftUI

struct AssignmentRow: View {
    let assignment: Assignment
    let isNextDue: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(assignment.title)
                    .font(.headline)
                Text("Due: \(assignment.dueDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isNextDue {
                Text("Next Due")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}
