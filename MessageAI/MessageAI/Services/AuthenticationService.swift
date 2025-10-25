//
//  AuthenticationService.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseAuth

/// Service for handling Firebase Authentication operations
final class AuthenticationService {
    // MARK: - Singleton
    
    static let shared = AuthenticationService()
    
    private let auth = Auth.auth()
    
    private init() {}
    
    // MARK: - Authentication State
    
    /// Current authenticated user ID
    var currentUserID: String? {
        auth.currentUser?.uid
    }
    
    /// Whether a user is currently authenticated
    var isAuthenticated: Bool {
        auth.currentUser != nil
    }
    
    // MARK: - Sign Up
    
    /// Creates a new user account with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: User ID of created account
    /// - Throws: AppError if sign up fails
    func signUp(email: String, password: String) async throws -> String {
        guard email.isValidEmail else {
            throw AppError.invalidEmail
        }
        
        guard password.hasMinimumLength(AppConstants.Validation.minPasswordLength) else {
            throw AppError.weakPassword
        }
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return result.user.uid
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Sign In
    
    /// Signs in an existing user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Returns: User ID of signed-in account
    /// - Throws: AppError if sign in fails
    func signIn(email: String, password: String) async throws -> String {
        guard email.isValidEmail else {
            throw AppError.invalidEmail
        }
        
        guard password.isNotEmpty else {
            throw AppError.invalidCredentials
        }
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user.uid
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    // MARK: - Sign Out
    
    /// Signs out the current user
    /// - Throws: AppError if sign out fails
    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw AppError.serverError("Failed to sign out")
        }
    }
    
    // MARK: - User Management
    
    /// Gets current Firebase user
    /// - Returns: Firebase User or nil if not authenticated
    func getCurrentUser() -> FirebaseAuth.User? {
        auth.currentUser
    }
    
    /// Updates user profile
    /// - Parameter displayName: New display name
    /// - Throws: AppError if update fails
    func updateProfile(displayName: String) async throws {
        guard let user = auth.currentUser else {
            throw AppError.notAuthenticated
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        
        do {
            try await changeRequest.commitChanges()
        } catch {
            throw AppError.serverError("Failed to update profile")
        }
    }
    
    // MARK: - Error Mapping
    
    /// Maps Firebase Auth errors to AppError
    /// - Parameter error: Firebase Auth error
    /// - Returns: Mapped AppError
    private func mapAuthError(_ error: NSError) -> AppError {
        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
            return .serverError(error.localizedDescription)
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .userNotFound:
            return .userNotFound
        case .wrongPassword:
            return .invalidCredentials
        case .userDisabled:
            return .accountDisabled
        case .networkError:
            return .networkUnavailable
        case .tooManyRequests:
            return .rateLimitExceeded
        default:
            return .serverError(error.localizedDescription)
        }
    }
}
