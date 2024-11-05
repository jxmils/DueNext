//
//  Assignments.swift
//  DueNext
//
//  Created by Jason Miller on 11/4/24.
//

import Foundation

class Assignment: Identifiable, Codable, ObservableObject {
    var id: UUID = UUID()
    var title: String
    var dueDate: Date

    init(title: String, dueDate: Date) {
        self.title = title
        self.dueDate = dueDate
    }
}
