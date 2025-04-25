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
                // MARK: Assignment Title
                TextField("Assignment Title", text: $title)
                    .disableAutocorrection(true)
                    .font(.title3)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .submitLabel(.done)
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
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .foregroundColor(.blue)
                        }

                        Button {
                            showTimePicker = true
                        } label: {
                            Text("⏰ \(dueDate, formatter: timeFormatter)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .foregroundColor(.blue)
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
                        // Existing subjects
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
                            .padding(.vertical, 16)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(subject == selectedSubject ? Color.blue : Color.clear)
                            )
                            .onTapGesture {
                                // Cancel any in-progress "add subject"
                                withAnimation(.easeInOut) {
                                    isAddingSubject = false
                                    selectedSubject = subject
                                }
                            }
                        }
                        .onDelete(perform: deleteSubject)

                        // Add-new-subject row
                        Group {
                            if isAddingSubject {
                                HStack {
                                    TextField("New Subject", text: $newSubject)
                                        .autocapitalization(.words)
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .submitLabel(.done)
                                        .onSubmit(addNewSubject)

                                    Button {
                                        addNewSubject()
                                    } label: {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .padding(.vertical, 4)
                            } else {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Add New Subject")
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        isAddingSubject = true
                                    }
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .padding(.vertical, 16)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .frame(maxHeight: .infinity)
                    .layoutPriority(1)
                }

                // MARK: Add Assignment Button
                Button {
                    viewModel.addAssignment(
                        title: title.trimmingCharacters(in: .whitespaces),
                        dueDate: dueDate,
                        subject: selectedSubject!
                    )
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Add Assignment")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            (title.trimmingCharacters(in: .whitespaces).isEmpty ||
                             selectedSubject == nil)
                                ? Color.gray : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(
                    title.trimmingCharacters(in: .whitespaces).isEmpty ||
                    selectedSubject == nil
                )
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

    // MARK: - Helpers

    private func addNewSubject() {
        let trimmed = newSubject.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !viewModel.allSubjects.contains(trimmed) else { return }
        viewModel.addCustomSubject(trimmed)
        selectedSubject = trimmed
        newSubject = ""
        withAnimation(.easeInOut) {
            isAddingSubject = false
        }
    }

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
