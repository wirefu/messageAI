//
//  AIChatInterfaceView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Main AI Chat Interface view with session management and chat functionality
struct AIChatInterfaceView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = AIChatViewModel()
    @State private var showingNewSession = false
    @State private var selectedSessionID: String?
    
    var body: some View {
        NavigationView {
            AIChatView()
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    profileButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    newSessionButton
                }
            }
            .sheet(isPresented: $showingNewSession) {
                NewAISessionView { session in
                    selectedSessionID = session.id
                    showingNewSession = false
                }
            }
            .task {
                // Initialize AI Chat session
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    private var profileButton: some View {
        Menu {
            if let user = authViewModel.currentUser {
                Text(user.displayName)
                    .font(.headline)
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
            }
            
            Button(role: .destructive) {
                Task {
                    await authViewModel.signOut()
                }
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            Image(systemName: "person.circle.fill")
                .font(.title2)
        }
    }
    
    private var newSessionButton: some View {
        Button {
            showingNewSession = true
        } label: {
            Image(systemName: "plus")
        }
    }
}
