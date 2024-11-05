//
//  AddAssignmentView.swift
//  DueNext
//
//  Created by Jason Miller on 11/4/24.
//

import SwiftUI

struct AddAssignmentView: View {
    @ObservedObject var viewModel: AssignmentViewModel
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedSubject: String = "Math" // Default subject
    @State private var customSubject: String = ""       // For custom entry
    @State private var isCustomSubject: Bool = false    // Track if "Other" is selected
    @Environment(\.presentationMode) private var presentationMode // Access the presentation mode

    var body: some View {
        Form {
            TextField("Assignment Title", text: $title)
            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)

            // Subject Picker
            Picker("Subject", selection: $selectedSubject) {
                ForEach(viewModel.allSubjects, id: \.self) { subject in
                    Text(subject)
                }
            }
            .onChange(of: selectedSubject) { newSubject in
                isCustomSubject = (newSubject == "Add New Subject")
                customSubject = "" // Clear custom input when switching
            }

            // Show custom subject TextField if "Other" is selected
            if isCustomSubject {
                TextField("Enter Custom Subject", text: $customSubject)
                    .onChange(of: customSubject) { newCustomSubject in
                        if !newCustomSubject.isEmpty {
                            viewModel.addCustomSubject(newCustomSubject)
                            selectedSubject = newCustomSubject
                        }
                    }
            }

            Button("Add Assignment") {
                let subject = isCustomSubject && !customSubject.isEmpty ? customSubject : selectedSubject
                viewModel.addAssignment(title: title, dueDate: dueDate, subject: subject)
                presentationMode.wrappedValue.dismiss() // Dismiss the view after adding the assignment
            }
        }
    }
}
