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
    @State private var dueDate: Date = Calendar.current.date(
        bySettingHour: 23, minute: 59, second: 0, of: Date()
    ) ?? Date()
    @State private var selectedSubject: String?
    @State private var newSubject: String = ""
    @State private var isAddingSubject: Bool = false
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                // MARK: Title
                GeometryReader { geo in
                    TextField("Assignment Title", text: $title)
                        .disableAutocorrection(true)
                        .font(.title3)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(width: geo.size.width, height: 44)
                }
                .frame(height: 44)
                .padding(.horizontal)

                // MARK: Due Date & Time
                VStack(spacing: 16) {
                    Text("Due Date & Time")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        Button {
                            showDatePicker = true
                        } label: {
                            Text("📅 \(dueDate, formatter: dateFormatter)")
                                .frame(maxWidth: .infinity)
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }

                        Button {
                            showTimePicker = true
                        } label: {
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

                // MARK: Subjects
                VStack(alignment: .leading, spacing: 8) {
                    Text("Subjects")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    List {
                        // 1️⃣ Existing subjects
                        ForEach(viewModel.allSubjects, id: \.self) { subject in
                            HStack {
                                Text(subject)
                                    .foregroundColor(subject == selectedSubject ? .white : .primary)
                                Spacer()
                                if subject == selectedSubject {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(subject == selectedSubject ? Color.blue : Color.clear)
                            )
                            .onTapGesture {
                                selectedSubject = subject
                            }
                        }
                        .onDelete(perform: deleteSubject)

                        // 2️⃣ Add-New-Subject row
                        if isAddingSubject {
                            HStack {
                                TextField("New Subject", text: $newSubject)
                                    .autocapitalization(.words)
                                    .padding(.vertical, 8)
                                Button {
                                    let trimmed = newSubject.trimmingCharacters(in: .whitespaces)
                                    guard !trimmed.isEmpty,
                                          !viewModel.allSubjects.contains(trimmed)
                                    else { return }
                                    viewModel.addCustomSubject(trimmed)
                                    selectedSubject = trimmed
                                    newSubject = ""
                                    withAnimation { isAddingSubject = false }
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)

                        } else {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                                Text("Add New Subject")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation { isAddingSubject = true }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    // Ensure the list is tall enough to always show at least the "Add New Subject" row
                    .frame(minHeight: 80, maxHeight: 300)
                }

                Spacer()

                // MARK: Add Assignment Button
                Button {
                    guard let subject = selectedSubject,
                          viewModel.allSubjects.contains(subject) else {
                        selectedSubject = nil
                        return
                    }
                    viewModel.addAssignment(title: title, dueDate: dueDate, subject: subject)
                    presentationMode.wrappedValue.dismiss()
                } label: {
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
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(dueDate: $dueDate, isPresented: $showDatePicker)
            }
            .sheet(isPresented: $showTimePicker) {
                TimePickerSheet(dueDate: $dueDate, isPresented: $showTimePicker)
            }
        }
    }

    // MARK: Helpers

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }

    private func deleteSubject(at offsets: IndexSet) {
        for index in offsets {
            let subject = viewModel.allSubjects[index]
            if viewModel.predefinedSubjects.contains(subject) {
                viewModel.removePredefinedSubject(subject)
            } else {
                viewModel.removeCustomSubject(subject)
            }
            if selectedSubject == subject {
                selectedSubject = nil
            }
        }
    }
}

// MARK: - DatePickerSheet

private struct DatePickerSheet: View {
    @Binding var dueDate: Date
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $dueDate,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
            Button("Done") {
                isPresented = false
            }
            .padding()
        }
        .presentationDetents([.medium])
    }
}

// MARK: - TimePickerSheet

private struct TimePickerSheet: View {
    @Binding var dueDate: Date
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            DatePicker(
                "Select Time",
                selection: $dueDate,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(WheelDatePickerStyle())
            .padding()
            Button("Done") {
                isPresented = false
            }
            .padding()
        }
        .presentationDetents([.medium])
    }
}
