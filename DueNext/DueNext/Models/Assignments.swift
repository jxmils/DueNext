//
//  Assignment.swift
//  DueNext
//
//  Created by Jason Miller on 11/4/24.
//

import Foundation

class Assignment: Identifiable, Codable, ObservableObject {
    var id: UUID = UUID()
    var title: String
    var dueDate: Date
    var subject: String // New subject property
    var isCompleted: Bool // Removed `@Published` for `Codable` compatibility
    var completionDate: Date? = nil

    init(title: String, dueDate: Date, subject: String, isCompleted: Bool = false, completionDate: Date? = nil) {
        self.title = title
        self.dueDate = dueDate
        self.subject = subject
        self.isCompleted = isCompleted
        self.completionDate = completionDate
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case dueDate
        case subject
        case isCompleted
        case completionDate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        subject = try container.decode(String.self, forKey: .subject)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        completionDate = try container.decodeIfPresent(Date.self, forKey: .completionDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(subject, forKey: .subject)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(completionDate, forKey: .completionDate)
    }
}
