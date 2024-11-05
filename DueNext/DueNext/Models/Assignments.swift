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
    var isCompleted: Bool  // Removed `@Published` for `Codable` compatibility

    init(title: String, dueDate: Date, isCompleted: Bool = false) {
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case dueDate
        case isCompleted
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(isCompleted, forKey: .isCompleted)
    }
}
