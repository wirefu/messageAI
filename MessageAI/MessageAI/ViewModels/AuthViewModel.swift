//
//  AuthViewModel.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import Combine

/// ViewModel for authentication state and operations
@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: AppError?
    
    // MARK: - Dependencies
    
    private let authService: AuthenticationService
    private let userRepository: UserRepositoryProtocol
    
    // MARK: - Initialization
    
    init(
        authService: AuthenticationService = .shared,
        userRepository: UserRepositoryProtocol = UserRepository()
    ) {
        self.authService = authService
        self.userRepository = userRepository
        
        // Only check auth state if we actually have a current user
        if authService.isAuthenticated {
            Task {
                await checkAuthState()
            }
        }
    }
    
    // MARK: - Authentication Operations
    
    /// Signs up a new user
    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            guard displayName.hasMinimumLength(AppConstants.Validation.minDisplayNameLength) else {
                error = .invalidData
                return
            }
            
            let userID = try await authService.signUp(email: email, password: password)
            
            let user = User(
                id: userID,
                displayName: displayName,
                email: email,
                avatarURL: nil,
                isOnline: true,
                lastSeen: Date(),
                fcmToken: nil,
                createdAt: Date()
            )
            
            try await userRepository.createUser(user)
            try await authService.updateProfile(displayName: displayName)
            
            currentUser = user
            isAuthenticated = true
            
            try await userRepository.setOnlineStatus(userID: userID, isOnline: true)
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = .serverError("Sign up failed")
        }
    }
    
    /// Signs in an existing user
    func signIn(email: String, password: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let userID = try await authService.signIn(email: email, password: password)
            
            guard let user = try await userRepository.getUser(id: userID) else {
                error = .userNotFound
                return
            }
            
            currentUser = user
            isAuthenticated = true
            
            try await userRepository.setOnlineStatus(userID: userID, isOnline: true)
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = .invalidCredentials
        }
    }
    
    /// Signs out the current user
    func signOut() async {
        guard let userID = currentUser?.id else { return }
        
        try? await userRepository.setOnlineStatus(userID: userID, isOnline: false)
        
        do {
            try authService.signOut()
            currentUser = nil
            isAuthenticated = false
            error = nil
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = .serverError("Failed to sign out")
        }
    }
    
    // MARK: - State Management
    
    private func checkAuthState() async {
        guard let userID = authService.currentUserID else {
            isAuthenticated = false
            currentUser = nil
            return
        }
        
        do {
            if let user = try await userRepository.getUser(id: userID) {
                currentUser = user
                isAuthenticated = true
                try await userRepository.setOnlineStatus(userID: userID, isOnline: true)
            } else {
                isAuthenticated = false
                currentUser = nil
            }
        } catch {
            try? authService.signOut()
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func clearError() {
        error = nil
    }
}
