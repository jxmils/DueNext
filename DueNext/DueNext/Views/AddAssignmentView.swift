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
    // Default due date is set to today at 11:59 PM
    @State private var dueDate: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date()
    @State private var selectedSubject: String = "Math" // Default subject
    @State private var customSubject: String = ""       // For custom entry
    @State private var isCustomSubject: Bool = false    // Track if custom subject is selected
    @Environment(\.presentationMode) private var presentationMode // Access the presentation mode

    var body: some View {
        Form {
            TextField("Assignment Title", text: $title)
            
            // Compact DatePicker for selecting due date and time
            DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .onChange(of: dueDate) { _ in
                    // Automatically close after selecting a time
                    // Additional logic could be added here if needed
                }

            // Subject Picker
            Picker("Subject", selection: $selectedSubject) {
                ForEach(viewModel.allSubjects + ["Add New Subject"], id: \.self) { subject in
                    Text(subject)
                }
            }
            .onChange(of: selectedSubject) { newSubject in
                isCustomSubject = (newSubject == "Add New Subject")
                customSubject = "" // Clear custom input when switching to a new custom subject
            }

            // Show custom subject TextField if "Add New Subject" is selected
            if isCustomSubject {
                TextField("Enter Custom Subject", text: $customSubject)
                    .padding(.vertical)

                Button("Add Custom Subject") {
                    if !customSubject.isEmpty && !viewModel.customSubjects.contains(customSubject) {
                        viewModel.addCustomSubject(customSubject)
                        selectedSubject = customSubject // Update picker to the new custom subject
                        isCustomSubject = false         // Reset custom subject input state
                    }
                }
            }

            Button("Add Assignment") {
                let subject = isCustomSubject && !customSubject.isEmpty ? customSubject : selectedSubject
                viewModel.addAssignment(title: title, dueDate: dueDate, subject: subject)
                presentationMode.wrappedValue.dismiss() // Dismiss the view after adding the assignment
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
