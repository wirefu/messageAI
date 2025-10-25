//
//  MessengerAIApp.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI
import FirebaseCore

@main
struct MessengerAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate
    
    @StateObject private var authViewModel = AuthViewModel()
    
    #if DEBUG
    init() {
        Bundle(path: "/Applications/InjectionNext.app/Contents/Resources/iOSInjection.bundle")?.load()
    }
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var onboardingManager = AIFeaturesOnboardingManager()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .sheet(isPresented: $onboardingManager.shouldShowOnboarding) {
                        AIFeaturesOnboardingView(isPresented: $onboardingManager.shouldShowOnboarding)
                    }
                    #if DEBUG
                    .overlay(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                        CostMonitorView()
                            .padding()
                    }
                    #endif
            } else {
                AuthContainerView()
            }
        }
    }
}
