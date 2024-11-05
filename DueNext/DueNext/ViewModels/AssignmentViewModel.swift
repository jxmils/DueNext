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

    init() {
        loadAssignments()
        updateNextDueAssignment()
    }

    func addAssignment(title: String, dueDate: Date) {
        let newAssignment = Assignment(title: title, dueDate: dueDate)
        assignments.append(newAssignment)
        saveAssignments()           // Save all assignments after adding
        updateNextDueAssignment()    // Update the next due assignment
    }

    private func updateNextDueAssignment() {
        nextDueAssignment = assignments
            .filter { $0.dueDate > Date() }
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
    
    // MARK: - Filtering Method for Main View
    enum AssignmentFilter {
        case today, tomorrow, thisWeek
    }

    func filteredAssignments(for filter: AssignmentFilter) -> [Assignment] {
        let calendar = Calendar.current
        let today = Date()
        
        return assignments.filter { assignment in
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
}
