import Foundation
import Combine

class AssignmentViewModel: ObservableObject {
    @Published var assignments: [Assignment] = []
    @Published var nextDueAssignment: Assignment?
    
    private let userDefaults = UserDefaults(suiteName: "group.com.jasonmiller.DueNext")
    
    private let predefinedSubjectsKey = "predefinedSubjects"
    private let customSubjectsKey = "customSubjects"

    // Predefined subjects list loaded from UserDefaults or set as defaults
    @Published var predefinedSubjects: [String] = {
        let userDefaults = UserDefaults(suiteName: "group.com.jasonmiller.DueNext")
        if let savedPredefinedSubjects = userDefaults?.array(forKey: "predefinedSubjects") as? [String] {
            return savedPredefinedSubjects
        } else {
            return ["Math", "Science", "History", "English", "Art"]
        }
    }()
    
    // Custom subjects loaded from UserDefaults or set as an empty array
    @Published var customSubjects: [String] = {
        let userDefaults = UserDefaults(suiteName: "group.com.jasonmiller.DueNext")
        return userDefaults?.array(forKey: "customSubjects") as? [String] ?? []
    }()

    // Combined list of predefined and custom subjects
    var allSubjects: [String] {
        return predefinedSubjects + customSubjects
    }

    init() {
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
        saveCustomSubjects()
    }
    
    func removeCustomSubject(_ subject: String) {
        if let index = customSubjects.firstIndex(of: subject) {
            customSubjects.remove(at: index)
            saveCustomSubjects()
        }
    }
    
    // Save predefined subjects to UserDefaults
    private func savePredefinedSubjects() {
        userDefaults?.set(predefinedSubjects, forKey: predefinedSubjectsKey)
    }

    // Save custom subjects to UserDefaults
    private func saveCustomSubjects() {
        userDefaults?.set(customSubjects, forKey: customSubjectsKey)
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
