//
//  AppDelegate.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        #if DEBUG
        // Use Firebase Emulator for local testing
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        
        print("🔥 Using Firebase Emulator (Auth: 9099, Firestore: 8080)")
        #else
        // Production: Enable Firestore offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        print("🔥 Using Production Firebase")
        #endif
        
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
