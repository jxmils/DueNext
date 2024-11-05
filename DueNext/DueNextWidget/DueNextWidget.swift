//
//  DueNextWidget.swift
//  DueNextWidget
//
//  Created by Jason Miller on 11/4/24.
//

import WidgetKit
import SwiftUI

// MARK: - Data Provider for the Widget
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), assignmentTitle: "Sample Assignment", dueDate: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = fetchNextAssignmentEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = fetchNextAssignmentEntry()
        let timeline = Timeline(entries: [entry], policy: .after(entry.dueDate))
        completion(timeline)
    }
    
    // Helper function to fetch the next assignment from UserDefaults
    private func fetchNextAssignmentEntry() -> SimpleEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.jasonmiller.DueNext")
        
        if let data = sharedDefaults?.data(forKey: "nextAssignment"),
           let assignment = try? JSONDecoder().decode(Assignment.self, from: data) {
            print("Widget loaded assignment:", assignment.title, "Due:", assignment.dueDate)
            return SimpleEntry(date: Date(), assignmentTitle: assignment.title, dueDate: assignment.dueDate)
        } else {
            print("No assignment found in UserDefaults.")
            return SimpleEntry(date: Date(), assignmentTitle: "No Assignments", dueDate: Date())
        }
    }
}

// MARK: - Entry Structure
struct SimpleEntry: TimelineEntry {
    let date: Date
    let assignmentTitle: String
    let dueDate: Date
}

// MARK: - Widget View
struct DueNextWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Assignment:")
                .font(.headline)
            
            Text(entry.assignmentTitle)
                .font(.title2)
                .bold()
            
            Text("Due: \(entry.dueDate, style: .time)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct DueNextWidget: Widget {
    let kind: String = "DueNextWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DueNextWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("DueNext")
        .description("Displays your next due assignment.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    DueNextWidget()
} timeline: {
    SimpleEntry(date: .now, assignmentTitle: "Physics Assignment", dueDate: Date().addingTimeInterval(3600))
}
