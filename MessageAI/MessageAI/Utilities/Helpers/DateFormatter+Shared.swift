//
//  DateFormatter+Shared.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// Shared date formatters to avoid repeated creation
enum SharedDateFormatters {
    // MARK: - Message Formatters

    /// Formatter for message timestamps (e.g., "2:30 PM")
    static let messageTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.TimeFormats.messageTime
        formatter.locale = Locale.current
        return formatter
    }()

    /// Formatter for message dates (e.g., "Oct 23, 2025")
    static let messageDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.TimeFormats.messageDate
        formatter.locale = Locale.current
        return formatter
    }()

    /// Formatter for full date and time (e.g., "Oct 23, 2025 at 2:30 PM")
    static let fullDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.TimeFormats.fullDateTime
        formatter.locale = Locale.current
        return formatter
    }()

    /// Formatter for relative days (e.g., "Monday", "Tuesday")
    static let relativeDays: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstants.TimeFormats.relativeDays
        formatter.locale = Locale.current
        return formatter
    }()

    // MARK: - ISO 8601 Formatter

    /// ISO 8601 formatter for API communication
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    // MARK: - Relative Date Formatter

    /// Relative date formatter (e.g., "2 hours ago")
    static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}
