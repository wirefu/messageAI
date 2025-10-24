//
//  AppDelegate.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Enable Firestore offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        
        print("✅ Firebase configured successfully")
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("📱 App will resign active")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📱 App did become active")
    }
}
