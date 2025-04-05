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
            print("DEBUG: Loaded predefined subjects from UserDefaults: \(savedPredefinedSubjects)")
            return savedPredefinedSubjects
        } else {
            print("DEBUG: Using default predefined subjects.")
            return ["Math", "Science", "History", "English", "Art"]
        }
    }()
    
    // Custom subjects loaded from UserDefaults or set as an empty array
    @Published var customSubjects: [String] = {
        let userDefaults = UserDefaults(suiteName: "group.com.jasonmiller.DueNext")
        if let savedCustomSubjects = userDefaults?.array(forKey: "customSubjects") as? [String] {
            print("DEBUG: Loaded custom subjects from UserDefaults: \(savedCustomSubjects)")
            return savedCustomSubjects
        } else {
            print("DEBUG: No custom subjects found. Using an empty list.")
            return []
        }
    }()

    // Combined list of predefined and custom subjects
    var allSubjects: [String] {
        return predefinedSubjects + customSubjects
    }

    init() {
        print("DEBUG: Initializing AssignmentViewModel.")
        loadAssignments()
        updateNextDueAssignment()
    }

    func addAssignment(title: String, dueDate: Date, subject: String) {
        let newAssignment = Assignment(title: title, dueDate: dueDate, subject: subject)
        assignments.append(newAssignment)
        print("DEBUG: Added assignment: \(newAssignment)")
        saveAssignments()
        updateNextDueAssignment()
    }

    func toggleCompletion(for assignment: Assignment) {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            if !assignments[index].isCompleted {
                // Marking as complete: set completionDate to now
                assignments[index].isCompleted = true
                assignments[index].completionDate = Date()
            } else {
                // Marking as incomplete: clear the completionDate
                assignments[index].isCompleted = false
                assignments[index].completionDate = nil
            }
            print("DEBUG: Toggled completion for assignment: \(assignments[index])")
            saveAssignments()
            updateNextDueAssignment()
        }
    }

    func addCustomSubject(_ subject: String) {
        print("DEBUG: Attempting to add custom subject: \(subject). Current list: \(customSubjects)")
        guard !customSubjects.contains(subject) else {
            print("DEBUG: Subject already exists: \(subject)")
            return
        }
        customSubjects.append(subject)
        print("DEBUG: Custom subject added: \(subject). Updated list: \(customSubjects)")
        saveCustomSubjects() // Ensure this is called
    }
    
    func removeCustomSubject(_ subject: String) {
        print("DEBUG: Attempting to remove custom subject: \(subject). Current list: \(customSubjects)")
        if let index = customSubjects.firstIndex(of: subject) {
            customSubjects.remove(at: index)
            print("DEBUG: Custom subject removed: \(subject). Updated list: \(customSubjects)")
            saveCustomSubjects() // Ensure this is called
        } else {
            print("DEBUG: Subject not found: \(subject).")
        }
    }
    
    func delete(_ assignment: Assignment) {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments.remove(at: index)
            print("DEBUG: Deleted assignment: \(assignment)")
            saveAssignments()
            updateNextDueAssignment()
        }
    }
    
    func addPredefinedSubject(_ subject: String) {
        guard !predefinedSubjects.contains(subject) else {
            print("DEBUG: Attempted to add duplicate predefined subject: \(subject)")
            return
        }
        predefinedSubjects.append(subject)
        savePredefinedSubjects()
    }
    
    private func savePredefinedSubjects() {
        userDefaults?.set(predefinedSubjects, forKey: predefinedSubjectsKey)
        print("DEBUG: Saved predefined subjects: \(predefinedSubjects)")
    }

    func removePredefinedSubject(_ subject: String) {
        if let index = predefinedSubjects.firstIndex(of: subject) {
            predefinedSubjects.remove(at: index)
            savePredefinedSubjects()
        } else {
            print("DEBUG: Attempted to remove non-existent predefined subject: \(subject)")
        }
    }
    
    private func saveCustomSubjects() {
        userDefaults?.set(customSubjects, forKey: customSubjectsKey)
        print("DEBUG: Saved custom subjects: \(customSubjects)")
    }

    private func updateNextDueAssignment() {
        nextDueAssignment = assignments
            .filter { $0.dueDate > Date() && !$0.isCompleted }
            .min(by: { $0.dueDate < $1.dueDate })

        if let nextDue = nextDueAssignment, let encoded = try? JSONEncoder().encode(nextDue) {
            userDefaults?.set(encoded, forKey: "nextAssignment")
            print("DEBUG: Updated next due assignment: \(nextDue)")
        }
    }

    private func saveAssignments() {
        if let encoded = try? JSONEncoder().encode(assignments) {
            userDefaults?.set(encoded, forKey: "assignments")
            print("DEBUG: Saved assignments to UserDefaults.")
        }
    }

    func loadAssignments() {
        if let data = userDefaults?.data(forKey: "assignments"),
           let savedAssignments = try? JSONDecoder().decode([Assignment].self, from: data) {
            assignments = savedAssignments
            print("DEBUG: Loaded assignments from UserDefaults: \(assignments)")
            updateNextDueAssignment()
        } else {
            print("DEBUG: No assignments found in UserDefaults.")
        }
    }

    // MARK: - Completion Percentage for Workload Overview
    var completionPercentage: Double {
        let completedCount = assignments.filter { $0.isCompleted }.count
        let totalCount = assignments.count
        print("DEBUG: Completion percentage calculated. Completed: \(completedCount), Total: \(totalCount)")
        return totalCount > 0 ? (Double(completedCount) / Double(totalCount)) * 100 : 0
    }

    // MARK: - Filtering Method for Main View
    enum AssignmentFilter {
        case today, tomorrow, thisWeek
    }

    func filteredAssignments(for filter: AssignmentFilter) -> [Assignment] {
        let calendar = Calendar.current
        let today = Date()
        
        let filtered = assignments.filter { assignment in
            guard !assignment.isCompleted else { return false }
            switch filter {
            case .today:
                return calendar.isDateInToday(assignment.dueDate)
            case .tomorrow:
                return calendar.isDateInTomorrow(assignment.dueDate)
            case .thisWeek:
                return calendar.isDate(assignment.dueDate, equalTo: today, toGranularity: .weekOfYear) && assignment.dueDate > today
            }
        }
        print("DEBUG: Filtered assignments for \(filter): \(filtered)")
        return filtered
    }
    
    // MARK: - Weekly Calculations for Workload Overview
    var weeklyAssignmentsCount: Int {
        let count = assignments.filter { isWithinCurrentWeek($0.dueDate) }.count
        print("DEBUG: Weekly assignments count: \(count)")
        return count
    }

    var weeklyCompletedAssignmentsCount: Int {
        let count = assignments.filter { $0.isCompleted && isWithinCurrentWeek($0.dueDate) }.count
        print("DEBUG: Weekly completed assignments count: \(count)")
        return count
    }

    var weeklyCompletionPercentage: Double {
        let completed = weeklyCompletedAssignmentsCount
        let total = weeklyAssignmentsCount
        print("DEBUG: Weekly completion percentage calculated. Completed: \(completed), Total: \(total)")
        return total > 0 ? (Double(completed) / Double(total)) * 100 : 0
    }
    
    var weeklyCompletedOnTimeCount: Int {
        let calendar = Calendar.current
        // Get the start of the current week (using yearForWeekOfYear and weekOfYear)
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)
        else {
            return 0
        }
        
        return assignments.filter { assignment in
            // Skip assignments with an invalid due date
            if assignment.dueDate.timeIntervalSince1970 == 0 { return false }
            guard let completionDate = assignment.completionDate else { return false }
            // Check if the assignment's due date falls within the current week
            let isDueThisWeek = assignment.dueDate >= weekStart && assignment.dueDate < weekEnd
            // Consider it on time if it was completed on or before the due date
            return isDueThisWeek && (completionDate <= assignment.dueDate)
        }.count
    }
    
    private func isWithinCurrentWeek(_ date: Date) -> Bool {
        // Return false if the date is invalid
        if date.timeIntervalSince1970 == 0 { return false }
        let calendar = Calendar.current
        let isWithinWeek = calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        print("DEBUG: Checking if date \(date) is within the current week: \(isWithinWeek)")
        return isWithinWeek
    }
}
