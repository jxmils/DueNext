//
//  NotificationsManager.swift
//  DueNext
//
//  Created by Jason Miller on 11/5/24.
//

import UserNotifications

class NotificationsManager {
    static func scheduleReminder(for assignment: Assignment) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Assignment"
        content.body = "Don’t forget: \(assignment.title) is due \(formattedDate(assignment.dueDate))."
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: assignment.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: assignment.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
