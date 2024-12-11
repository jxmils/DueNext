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
    @State private var dueDate: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date()
    @State private var selectedSubject: String? // Track selected subject with an optional string
    @State private var customSubject: String = ""       // For custom entry
    @Environment(\.presentationMode) private var presentationMode // Access the presentation mode

    var body: some View {
        VStack {
            Form {
                TextField("Assignment Title", text: $title)
                
                // Compact DatePicker for selecting due date and time
                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)

                // Section to display and select subjects with a checkmark indicator
                Section(header: Text("Select Subject")) {
                    List {
                        ForEach(viewModel.allSubjects, id: \.self) { subject in
                            HStack {
                                Text(subject)
                                Spacer()
                                if subject == selectedSubject {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle()) // Make the entire row tappable
                            .onTapGesture {
                                selectedSubject = subject // Set the selected subject
                            }
                        }
                        .onDelete(perform: deleteSubject)
                    }
                }

                // Custom subject input for adding new subjects
                TextField("Enter New Subject", text: $customSubject)
                    .padding(.vertical)

                Button("Add Subject") {
                    if !customSubject.isEmpty && !viewModel.allSubjects.contains(customSubject) {
                        viewModel.addCustomSubject(customSubject) // Use the method to save the subject
                        customSubject = "" // Clear input
                    }
                }
                .padding(.vertical)
            }
            
            // "Add Assignment" button outside the form for separation
            Button("Add Assignment") {
                if let subject = selectedSubject {
                    viewModel.addAssignment(title: title, dueDate: dueDate, subject: subject)
                    presentationMode.wrappedValue.dismiss() // Dismiss the view after adding the assignment
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(selectedSubject == nil ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(selectedSubject == nil) // Disable if no subject is selected
        }
    }

    private func deleteSubject(at offsets: IndexSet) {
        for index in offsets {
            let subject = viewModel.allSubjects[index]
            if let predefinedIndex = viewModel.predefinedSubjects.firstIndex(of: subject) {
                viewModel.removePredefinedSubject(subject) // Persist removal
            } else if let customIndex = viewModel.customSubjects.firstIndex(of: subject) {
                viewModel.removeCustomSubject(subject) // Persist removal
            }
        }
    }

}
