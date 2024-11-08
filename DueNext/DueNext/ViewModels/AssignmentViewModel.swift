//
//  AssignmentViewModel.swift
//  DueNext
//
//  Created by Jason Miller on 11/4/24.
//

import Foundation
import Combine

class AssignmentViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var nextDueAssignment: Assignment?
    
    private let userDefaults = UserDefaults(suiteName: "group.com.jasonmiller.DueNext")

    // Predefined subjects list
    let predefinedSubjects = ["Math", "Science", "History", "English", "Art", "Other"]

    // New property to store custom subjects created by users
    @Published var customSubjects: [String] = []

    // Combined list of predefined and custom subjects
    var allSubjects: [String] {
        return predefinedSubjects + customSubjects
    }

    init() {
        #if DEBUG
        userDefaults?.removeObject(forKey: "assignments") // Clear cache for testing purposes
        userDefaults?.removeObject(forKey: "nextAssignment")
        #endif
        loadAssignments()
        updateNextDueAssignment()
    }

    func addAssignment(title: String, dueDate: Date, subject: String) {
        let newAssignment = Assignment(title: title, dueDate: dueDate, subject: subject)
        assignments.append(newAssignment)
        saveAssignments()           // Save all assignments after adding
        updateNextDueAssignment()    // Update the next due assignment
    }

    func toggleCompletion(for assignment: Assignment) {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments[index].isCompleted.toggle() // Toggle the completed status
            saveAssignments()                       // Save updated completion status
            updateNextDueAssignment()               // Update next due assignment if needed
        }
    }

    func addCustomSubject(_ subject: String) {
        guard !customSubjects.contains(subject) else { return }
        customSubjects.append(subject)
    }

    private func updateNextDueAssignment() {
        nextDueAssignment = assignments
            .filter { $0.dueDate > Date() && !$0.isCompleted } // Only include future, incomplete assignments
            .min(by: { $0.dueDate < $1.dueDate })

        // Save the next due assignment to UserDefaults
        if let nextDue = nextDueAssignment, let encoded = try? JSONEncoder().encode(nextDue) {
            userDefaults?.set(encoded, forKey: "nextAssignment")
        }
    }

    private func saveAssignments() {
        // Save the list of assignments to UserDefaults
        if let encoded = try? JSONEncoder().encode(assignments) {
            userDefaults?.set(encoded, forKey: "assignments")
        }
    }

    func loadAssignments() {
        if let data = userDefaults?.data(forKey: "assignments"),
           let savedAssignments = try? JSONDecoder().decode([Assignment].self, from: data) {
            assignments = savedAssignments
            updateNextDueAssignment()
        }
    }

    // MARK: - Completion Percentage for Workload Overview
    var completionPercentage: Double {
        let completedCount = assignments.filter { $0.isCompleted }.count
        let totalCount = assignments.count
        return totalCount > 0 ? (Double(completedCount) / Double(totalCount)) * 100 : 0
    }

    // MARK: - Filtering Method for Main View
    enum AssignmentFilter {
        case today, tomorrow, thisWeek
    }

    func filteredAssignments(for filter: AssignmentFilter) -> [Assignment] {
        let calendar = Calendar.current
        let today = Date()
        
        return assignments.filter { assignment in
            guard !assignment.isCompleted else { return false } // Filter out completed assignments
            switch filter {
            case .today:
                return calendar.isDateInToday(assignment.dueDate)
            case .tomorrow:
                return calendar.isDateInTomorrow(assignment.dueDate)
            case .thisWeek:
                return calendar.isDate(assignment.dueDate, equalTo: today, toGranularity: .weekOfYear) && assignment.dueDate > today
            }
        }
    }
    
    // MARK: - Weekly Calculations for Workload Overview

    // Total assignments for the current week
    var weeklyAssignmentsCount: Int {
        assignments.filter { isWithinCurrentWeek($0.dueDate) }.count
    }

    // Completed assignments for the current week
    var weeklyCompletedAssignmentsCount: Int {
        assignments.filter { $0.isCompleted && isWithinCurrentWeek($0.dueDate) }.count
    }

    // Weekly completion percentage
    var weeklyCompletionPercentage: Double {
        let completed = weeklyCompletedAssignmentsCount
        let total = weeklyAssignmentsCount
        return total > 0 ? (Double(completed) / Double(total)) * 100 : 0
    }
    
    // Helper to check if a date is within the current week
    private func isWithinCurrentWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}
