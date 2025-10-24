//
//  Date+Extensions.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

extension Date {
    // MARK: - Relative Date Formatting

    /// Returns a relative date string (Today, Yesterday, or date)
    /// - Returns: Formatted relative date string
    func relativeDate() -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = AppConstants.TimeFormats.relativeDays
            return formatter.string(from: self)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = AppConstants.TimeFormats.messageDate
            return formatter.string(from: self)
        }
    }

    /// Returns a time string (e.g., "2:30 PM")
    /// - Returns: Formatted time string
    func timeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.TimeFormats.messageTime
        return formatter.string(from: self)
    }

    /// Returns full date and time string
    /// - Returns: Formatted date and time string
    func fullDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.TimeFormats.fullDateTime
        return formatter.string(from: self)
    }

    // MARK: - Time Calculations

    /// Checks if date is within specified hours from now
    /// - Parameter hours: Number of hours to check
    /// - Returns: True if date is within the specified hours
    func isWithin(hours: Int) -> Bool {
        let timeInterval = TimeInterval(hours * 60 * 60)
        return abs(timeIntervalSinceNow) < timeInterval
    }

    /// Checks if date is older than specified hours
    /// - Parameter hours: Number of hours to check
    /// - Returns: True if date is older than specified hours
    func isOlderThan(hours: Int) -> Bool {
        let timeInterval = TimeInterval(hours * 60 * 60)
        return -timeIntervalSinceNow > timeInterval
    }

    /// Returns time ago string (e.g., "5 minutes ago", "2 hours ago")
    /// - Returns: Formatted time ago string
    func timeAgo() -> String {
        let interval = -timeIntervalSinceNow

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}
