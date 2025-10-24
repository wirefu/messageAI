//
//  NetworkMonitor.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import Foundation
import Network
import Combine

/// Monitors network connectivity status
final class NetworkMonitor: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .wifi
    
    // MARK: - Types
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case none
    }
    
    // MARK: - Properties
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.messengerai.networkmonitor")
    
    // MARK: - Singleton
    
    static let shared = NetworkMonitor()
    
    private init() {
        startMonitoring()
    }
    
    // MARK: - Monitoring
    
    /// Starts monitoring network status
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.determineConnectionType(from: path) ?? .none
            }
        }
        
        monitor.start(queue: queue)
    }
    
    /// Stops monitoring network status
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // MARK: - Private Helpers
    
    private func determineConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .none
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
