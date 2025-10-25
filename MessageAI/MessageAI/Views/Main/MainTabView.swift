//
//  MainTabView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Main tab view containing Messages and AI Assistant tabs
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var onboardingManager = AIFeaturesOnboardingManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Messages Tab
            ConversationListView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Messages")
                }
                .tag(0)
            
            // AI Assistant Tab
            AIChatInterfaceView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Assistant")
                }
                .tag(1)
        }
        .accentColor(.blue)
        .sheet(isPresented: $onboardingManager.shouldShowOnboarding) {
            AIFeaturesOnboardingView(isPresented: $onboardingManager.shouldShowOnboarding)
        }
        #if DEBUG
        .overlay(alignment: .topTrailing) {
            CostMonitorView()
                .padding()
        }
        #endif
    }
}
