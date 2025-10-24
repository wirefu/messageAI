//
//  AppError.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// Application-wide error types with user-friendly messages
enum AppError: LocalizedError, Equatable {
    // MARK: - Authentication Errors

    case notAuthenticated
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case userNotFound
    case accountDisabled

    // MARK: - Network Errors

    case networkUnavailable
    case requestTimeout
    case serverError(String)

    // MARK: - Data Errors

    case invalidData
    case decodingFailed
    case encodingFailed
    case missingRequiredField(String)

    // MARK: - Firestore Errors

    case firestoreError(String)
    case permissionDenied
    case documentNotFound
    case quotaExceeded

    // MARK: - Messaging Errors

    case messageTooLong
    case emptyMessage
    case conversationNotFound
    case sendFailed

    // MARK: - AI Feature Errors

    case aiFunctionError(String)
    case rateLimitExceeded
    case aiServiceUnavailable

    // MARK: - LocalizedError Implementation

    var errorDescription: String? {
        switch self {
        // Authentication
        case .notAuthenticated:
            return "Please sign in to continue"
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .weakPassword:
            return "Password must be at least 8 characters"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .userNotFound:
            return "No account found with this email"
        case .accountDisabled:
            return "This account has been disabled"

        // Network
        case .networkUnavailable:
            return "No internet connection. Please check your network."
        case .requestTimeout:
            return "Request timed out. Please try again."
        case .serverError(let message):
            return "Server error: \(message)"

        // Data
        case .invalidData:
            return "Invalid data received"
        case .decodingFailed:
            return "Failed to process data"
        case .encodingFailed:
            return "Failed to prepare data"
        case .missingRequiredField(let field):
            return "Missing required information: \(field)"

        // Firestore
        case .firestoreError(let message):
            return "Database error: \(message)"
        case .permissionDenied:
            return "You don't have permission to access this data"
        case .documentNotFound:
            return "Requested data not found"
        case .quotaExceeded:
            return "Service limit exceeded. Please try again later."

        // Messaging
        case .messageTooLong:
            return "Message is too long (max 10,000 characters)"
        case .emptyMessage:
            return "Message cannot be empty"
        case .conversationNotFound:
            return "Conversation not found"
        case .sendFailed:
            return "Failed to send message. Please try again."

        // AI Features
        case .aiFunctionError(let message):
            return "AI service error: \(message)"
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment."
        case .aiServiceUnavailable:
            return "AI features temporarily unavailable"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again"
        case .invalidCredentials, .userNotFound:
            return "Please check your email and password"
        case .weakPassword:
            return "Use a stronger password with letters, numbers, and symbols"
        case .rateLimitExceeded:
            return "Wait a few moments before trying again"
        case .sendFailed:
            return "Your message will be sent when connection is restored"
        default:
            return "Please try again or contact support if the problem persists"
        }
    }
}

