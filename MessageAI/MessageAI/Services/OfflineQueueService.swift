//
//  OfflineQueueService.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation

/// Service for queuing messages when offline
final class OfflineQueueService {
    // MARK: - Singleton
    
    static let shared = OfflineQueueService()
    
    private let userDefaults = UserDefaults.standard
    private let queueKey = "com.messengerai.offlineQueue"
    private let maxQueueSize = AppConstants.Messaging.maxOfflineQueueSize
    
    private init() {}
    
    // MARK: - Queue Operations
    
    /// Enqueues a message for later sending
    /// - Parameter message: Message to queue
    func enqueue(_ message: Message) {
        var queue = getQueue()
        
        // Prevent queue from growing too large
        guard queue.count < maxQueueSize else {
            print("⚠️ Offline queue full, dropping oldest message")
            queue.removeFirst()
        }
        
        queue.append(message)
        saveQueue(queue)
    }
    
    /// Dequeues all messages
    /// - Returns: Array of queued messages
    func dequeueAll() -> [Message] {
        let queue = getQueue()
        clearQueue()
        return queue
    }
    
    /// Checks if queue is empty
    /// - Returns: True if no messages queued
    func isEmpty() -> Bool {
        getQueue().isEmpty
    }
    
    /// Clears the entire queue
    func clearQueue() {
        userDefaults.removeObject(forKey: queueKey)
    }
    
    /// Gets count of queued messages
    /// - Returns: Number of messages in queue
    func count() -> Int {
        getQueue().count
    }
    
    // MARK: - Private Helpers
    
    private func getQueue() -> [Message] {
        guard let data = userDefaults.data(forKey: queueKey),
              let queue = try? JSONDecoder().decode([Message].self, from: data) else {
            return []
        }
        return queue
    }
    
    private func saveQueue(_ queue: [Message]) {
        if let data = try? JSONEncoder().encode(queue) {
            userDefaults.set(data, forKey: queueKey)
        }
    }
}
