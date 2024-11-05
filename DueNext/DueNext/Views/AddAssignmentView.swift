//
//  AddAssignmentView.swift
//  DueNext
//
//  Created by Jason Miller on 11/4/24.
//

import SwiftUI

struct AddAssignmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AssignmentViewModel
    @State private var title: String = ""
    @State private var dueDate: Date = Date()  // Default to today

    var body: some View {
        NavigationView {
            Form {
                TextField("Assignment Title", text: $title)
                
                // Date picker restricted to today and future dates
                DatePicker("Due Date", selection: $dueDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                
                Button("Save") {
                    viewModel.addAssignment(title: title, dueDate: dueDate)
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
            .navigationTitle("New Assignment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
