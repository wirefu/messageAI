//
//  UserRepository.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseFirestore

/// Protocol defining user data operations
protocol UserRepositoryProtocol {
    func createUser(_ user: User) async throws
    func getUser(id: String) async throws -> User?
    func updateUser(_ user: User) async throws
    func observeUser(id: String, completion: @escaping (User?) -> Void)
    func setOnlineStatus(userID: String, isOnline: Bool) async throws
    func updateLastSeen(userID: String) async throws
    func getAllUsers(excludingUserID: String) async throws -> [User]
}

/// Repository for user data operations with Firestore
final class UserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Create
    
    /// Creates a new user document in Firestore
    /// - Parameter user: User to create
    /// - Throws: AppError if creation fails
    func createUser(_ user: User) async throws {
        do {
            try await db.collection(FirebaseConstants.usersCollection)
                .document(user.id)
                .setData(user.toFirestore())
        } catch {
            throw AppError.firestoreError("Failed to create user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Read
    
    /// Fetches a user by ID
    /// - Parameter id: User ID
    /// - Returns: User or nil if not found
    /// - Throws: AppError if fetch fails
    func getUser(id: String) async throws -> User? {
        do {
            let document = try await db.collection(FirebaseConstants.usersCollection)
                .document(id)
                .getDocument()
            
            return User.from(document: document)
        } catch {
            throw AppError.firestoreError("Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update
    
    /// Updates an existing user
    /// - Parameter user: User with updated data
    /// - Throws: AppError if update fails
    func updateUser(_ user: User) async throws {
        do {
            try await db.collection(FirebaseConstants.usersCollection)
                .document(user.id)
                .updateData(user.toFirestore())
        } catch {
            throw AppError.firestoreError("Failed to update user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Real-time Observation
    
    /// Observes real-time changes to a user
    /// - Parameters:
    ///   - id: User ID to observe
    ///   - completion: Callback with updated user data
    func observeUser(id: String, completion: @escaping (User?) -> Void) {
        listener = db.collection(FirebaseConstants.usersCollection)
            .document(id)
            .addSnapshotListener { snapshot, error in
                if error != nil {
                    completion(nil)
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(nil)
                    return
                }
                
                completion(User.from(document: snapshot))
            }
    }
    
    /// Stops observing user changes
    func stopObserving() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - Presence Management
    
    /// Updates user online status
    /// - Parameters:
    ///   - userID: User ID
    ///   - isOnline: Online status
    /// - Throws: AppError if update fails
    func setOnlineStatus(userID: String, isOnline: Bool) async throws {
        do {
            try await db.collection(FirebaseConstants.usersCollection)
                .document(userID)
                .updateData([
                    FirebaseConstants.UserFields.isOnline: isOnline,
                    FirebaseConstants.UserFields.lastSeen: Timestamp(date: Date())
                ])
        } catch {
            throw AppError.firestoreError("Failed to update online status: \(error.localizedDescription)")
        }
    }
    
    /// Updates user's last seen timestamp
    /// - Parameter userID: User ID
    /// - Throws: AppError if update fails
    func updateLastSeen(userID: String) async throws {
        do {
            try await db.collection(FirebaseConstants.usersCollection)
                .document(userID)
                .updateData([
                    FirebaseConstants.UserFields.lastSeen: Timestamp(date: Date())
                ])
        } catch {
            throw AppError.firestoreError("Failed to update last seen: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Query
    
    /// Fetches all users except the specified user
    /// - Parameter excludingUserID: User ID to exclude
    /// - Returns: Array of users
    /// - Throws: AppError if fetch fails
    func getAllUsers(excludingUserID: String) async throws -> [User] {
        do {
            let snapshot = try await db.collection(FirebaseConstants.usersCollection)
                .getDocuments()
            
            return snapshot.documents
                .compactMap { User.from(document: $0) }
                .filter { $0.id != excludingUserID }
        } catch {
            throw AppError.firestoreError("Failed to fetch users: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        listener?.remove()
    }
}
