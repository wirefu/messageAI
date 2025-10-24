//
//  UserDefaultsManager.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// Manager for UserDefaults storage operations
final class UserDefaultsManager {
    // MARK: - Shared Instance

    static let shared = UserDefaultsManager()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Keys

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastSyncTimestamp = "lastSyncTimestamp"
        static let offlineMessageQueue = "offlineMessageQueue"
        static let cachedUserID = "cachedUserID"
    }

    // MARK: - Onboarding

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    // MARK: - Sync Management

    var lastSyncTimestamp: Date? {
        get { defaults.object(forKey: Keys.lastSyncTimestamp) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastSyncTimestamp) }
    }

    // MARK: - User Session

    var cachedUserID: String? {
        get { defaults.string(forKey: Keys.cachedUserID) }
        set { defaults.set(newValue, forKey: Keys.cachedUserID) }
    }

    // MARK: - Generic Storage

    /// Saves a Codable object to UserDefaults
    /// - Parameters:
    ///   - object: Object to save
    ///   - key: Storage key
    func save<T: Codable>(_ object: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(object) {
            defaults.set(encoded, forKey: key)
        }
    }

    /// Retrieves a Codable object from UserDefaults
    /// - Parameter key: Storage key
    /// - Returns: Decoded object or nil if not found
    func retrieve<T: Codable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    /// Gets boolean value for key
    /// - Parameter key: Storage key
    /// - Returns: Boolean value
    func bool(forKey key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    /// Sets value for key
    /// - Parameters:
    ///   - value: Value to set
    ///   - key: Storage key
    func set(_ value: Any?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    /// Removes value for specified key
    /// - Parameter key: Storage key
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    /// Clears all app-specific UserDefaults
    func clearAll() {
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
    }
}
