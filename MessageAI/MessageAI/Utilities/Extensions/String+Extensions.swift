//
//  String+Extensions.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

extension String {
    // MARK: - Validation

    /// Checks if string is a valid email address
    var isValidEmail: Bool {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", AppConstants.Validation.emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Checks if string is not empty or only whitespace
    var isNotEmpty: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Checks if string meets minimum length requirement
    /// - Parameter length: Minimum length
    /// - Returns: True if string is at least the specified length
    func hasMinimumLength(_ length: Int) -> Bool {
        count >= length
    }

    /// Checks if string doesn't exceed maximum length
    /// - Parameter length: Maximum length
    /// - Returns: True if string is within the maximum length
    func hasMaximumLength(_ length: Int) -> Bool {
        count <= length
    }

    // MARK: - Formatting

    /// Returns trimmed string (removes leading/trailing whitespace)
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns string with first letter capitalized
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }

    /// Truncates string to specified length with ellipsis
    /// - Parameter length: Maximum length before truncation
    /// - Returns: Truncated string with "..." if needed
    func truncated(toLength length: Int) -> String {
        if count <= length {
            return self
        }
        let endIndex = index(startIndex, offsetBy: length)
        return String(self[..<endIndex]) + "..."
    }

    // MARK: - Safety

    /// Returns empty string if nil, otherwise returns trimmed string
    /// - Parameter value: Optional string value
    /// - Returns: Non-optional trimmed string
    static func safe(_ value: String?) -> String {
        value?.trimmed ?? ""
    }
}

