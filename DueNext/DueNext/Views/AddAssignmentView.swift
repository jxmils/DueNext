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
    @State private var selectedSubject: String?
    @State private var newSubject: String = ""
    @State private var isAddingSubject: Bool = false
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Assignment Title
                GeometryReader { geometry in
                    HStack {
                        TextField("Assignment Title", text: $title)
                            .disableAutocorrection(true)
                            .font(.title3)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .frame(height: 44)
                            .frame(width: geometry.size.width)
                    }
                }
                .frame(height: 44)
                .padding(.horizontal)

                // Due Date and Time
                VStack(spacing: 16) {
                    Text("Due Date & Time")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        Button(action: {
                            showDatePicker = true
                        }) {
                            Text("📅 \(dueDate, formatter: dateFormatter)")
                                .frame(maxWidth: .infinity)
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }

                        Button(action: {
                            showTimePicker = true
                        }) {
                            Text("⏰ \(dueDate, formatter: timeFormatter)")
                                .frame(maxWidth: .infinity)
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }

                // Subjects
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Subjects")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Spacer()

                        // Plus Sign Expanding to Input
                        HStack {
                            if isAddingSubject {
                                TextField("New Subject", text: $newSubject)
                                    .font(.body)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .transition(.scale)

                                Button(action: {
                                    if !newSubject.isEmpty && !viewModel.allSubjects.contains(newSubject) {
                                        viewModel.addCustomSubject(newSubject)
                                        newSubject = ""
                                    }
                                    withAnimation {
                                        isAddingSubject = false
                                    }
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Button(action: {
                                    withAnimation {
                                        isAddingSubject = true
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Subject List with Swipe-to-Delete
                    List {
                        ForEach(viewModel.allSubjects, id: \.self) { subject in
                            HStack {
                                Text(subject)
                                    .font(.body)
                                    .foregroundColor(subject == selectedSubject ? .white : .primary)
                                Spacer()
                                if subject == selectedSubject {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(subject == selectedSubject ? Color.blue : Color.clear)
                            )
                            .onTapGesture {
                                selectedSubject = subject
                            }
                        }
                        .onDelete(perform: deleteSubject)
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                Spacer()

                // Add Assignment Button
                Button(action: {
                    if let subject = selectedSubject, viewModel.allSubjects.contains(subject) {
                        viewModel.addAssignment(title: title, dueDate: dueDate, subject: subject)
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        selectedSubject = nil // Ensure no invalid subject is selected
                    }
                }) {
                    Text("Add Assignment")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedSubject == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(selectedSubject == nil)
            }
            .navigationTitle("New Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showDatePicker) {
                GeometryReader { geometry in
                    VStack {
                        DatePicker("Select Date", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .onChange(of: dueDate) { newValue, transaction in
                                showDatePicker = false
                            }
                        Spacer()
                    }
                    .frame(minHeight: 500)
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showTimePicker) {
                VStack {
                    DatePicker("Select Time", selection: $dueDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .padding()
                    Button("Done") {
                        showTimePicker = false
                    }
                    .padding()
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    private func deleteSubject(at offsets: IndexSet) {
        for index in offsets {
            let subject = viewModel.allSubjects[index]
            if subject == selectedSubject {
                selectedSubject = nil // Clear the selected subject
            }
            if viewModel.predefinedSubjects.contains(subject) {
                viewModel.removePredefinedSubject(subject)
            } else if viewModel.customSubjects.contains(subject) {
                viewModel.removeCustomSubject(subject)
            }
        }
    }
}
