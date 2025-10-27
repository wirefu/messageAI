//
//  TestFirebaseConfig.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

/// Firebase configuration specifically for UI tests
/// Uses Firebase emulators to avoid affecting production data
enum TestFirebaseConfig {
    
    // MARK: - Emulator Configuration
    
    /// Configures Firebase to use emulators for testing
    static func configureForTesting() {
        // Configure Auth emulator
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        
        // Configure Firestore emulator
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isSSLEnabled = false
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        
        // Configure Functions emulator
        Functions.functions().useEmulator(withHost: "localhost", port: 5001)
        
        print("🧪 Firebase configured for testing with emulators")
    }
    
    // MARK: - Test Data Management
    
    /// Clears all test data from emulators
    static func clearTestData() async throws {
        let db = Firestore.firestore()
        
        // Clear all collections
        let collections = ["users", "conversations", "messages", "summaries", "actionItems", "proactiveSuggestions"]
        
        for collection in collections {
            let snapshot = try await db.collection(collection).getDocuments()
            for document in snapshot.documents {
                try await document.reference.delete()
            }
        }
        
        // Note: Cannot clear Auth users in client SDK
        // This would require Firebase Admin SDK
        print("⚠️ Cannot clear Auth users from client SDK")
        
        print("🧹 Test data cleared from emulators")
    }
    
    // MARK: - Test User Creation
    
    /// Creates a test user for UI tests
    static func createTestUser(email: String, password: String) async throws -> FirebaseAuth.User {
        // Sign out any existing user first
        try? Auth.auth().signOut()
        
        // Create new user
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Update display name
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = "Test User"
        try await changeRequest.commitChanges()
        
        print("👤 Test user created: \(email)")
        return result.user
    }
    
    /// Signs in a test user
    static func signInTestUser(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        print("🔐 Test user signed in: \(email)")
        return result.user
    }
    
    /// Signs out current user
    static func signOutUser() async throws {
        try Auth.auth().signOut()
        print("🚪 User signed out")
    }
    
    // MARK: - Test Data Setup
    
    /// Creates sample test data for UI tests
    static func createSampleTestData() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw TestError.noAuthenticatedUser
        }
        
        let db = Firestore.firestore()
        
        // Create a test conversation
        let conversationRef = db.collection("conversations").document()
        try await conversationRef.setData([
            "id": conversationRef.documentID,
            "title": "Test Conversation",
            "participants": [currentUser.uid],
            "createdAt": Timestamp(date: Date()),
            "lastMessageAt": Timestamp(date: Date()),
            "isActive": true
        ])
        
        // Create sample messages
        let messages = [
            "Hello! This is a test message.",
            "How are you doing today?",
            "I'm testing the UI functionality.",
            "This should help with our UI tests."
        ]
        
        for (index, messageText) in messages.enumerated() {
            let messageRef = conversationRef.collection("messages").document()
            try await messageRef.setData([
                "id": messageRef.documentID,
                "content": messageText,
                "senderID": currentUser.uid,
                "timestamp": Timestamp(date: Date().addingTimeInterval(TimeInterval(index * 60))),
                "status": "sent"
            ])
        }
        
        print("📝 Sample test data created")
    }
    
    // MARK: - Test Environment Detection
    
    /// Checks if running in UI test environment
    static var isUITestEnvironment: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    /// Checks if Firebase emulators are running
    static func checkEmulatorStatus() async -> Bool {
        do {
            // Try to connect to Firestore emulator
            let db = Firestore.firestore()
            _ = try await db.collection("test").document("test").getDocument()
            return true
        } catch {
            print("⚠️ Firebase emulators not running: \(error)")
            return false
        }
    }
}

// MARK: - Test Errors

enum TestError: LocalizedError {
    case noAuthenticatedUser
    case emulatorNotRunning
    case testDataCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user for test data creation"
        case .emulatorNotRunning:
            return "Firebase emulators are not running"
        case .testDataCreationFailed:
            return "Failed to create test data"
        }
    }
}
