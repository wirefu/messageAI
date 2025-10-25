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
            Group {
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    LoadingView(message: "Loading AI sessions...")
                } else if viewModel.sessions.isEmpty {
                    EmptyStateView(
                        icon: "brain.head.profile",
                        title: "No AI Sessions",
                        message: "Start a conversation with your AI assistant to get help with your messages",
                        actionTitle: "New AI Chat",
                        action: { showingNewSession = true }
                    )
                } else {
                    sessionList
                }
            }
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
                if let userID = authViewModel.currentUser?.id {
                    await viewModel.loadSessions(for: userID)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var sessionList: some View {
        List {
            ForEach(viewModel.sessions) { session in
                NavigationLink {
                    AIChatView(
                        session: session,
                        currentUserID: authViewModel.currentUser?.id ?? ""
                    )
                } label: {
                    AISessionRowView(session: session)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteSession(session)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            if let userID = authViewModel.currentUser?.id {
                await viewModel.loadSessions(for: userID)
            }
        }
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
