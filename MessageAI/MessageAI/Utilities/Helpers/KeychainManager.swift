//
//  KeychainManager.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import Security

/// Manager for secure Keychain storage operations
final class KeychainManager {
    // MARK: - Shared Instance

    static let shared = KeychainManager()

    private init() {}

    // MARK: - Keys

    enum Keys {
        static let authToken = "com.messengerai.authToken"
        static let refreshToken = "com.messengerai.refreshToken"
        static let userPassword = "com.messengerai.userPassword"
    }

    // MARK: - Save

    /// Saves a string value to Keychain
    /// - Parameters:
    ///   - value: String value to save
    ///   - key: Keychain key
    /// - Returns: True if successful
    @discardableResult
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Retrieve

    /// Retrieves a string value from Keychain
    /// - Parameter key: Keychain key
    /// - Returns: String value or nil if not found
    func retrieve(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    // MARK: - Delete

    /// Deletes a value from Keychain
    /// - Parameter key: Keychain key
    /// - Returns: True if successful
    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    /// Clears all keychain items for the app
    @discardableResult
    func clearAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

