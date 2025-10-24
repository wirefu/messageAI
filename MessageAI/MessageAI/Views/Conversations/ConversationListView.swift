//
//  ConversationListView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Main view displaying list of user's conversations
struct ConversationListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ConversationListViewModel()
    @State private var showingNewConversation = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.conversations.isEmpty {
                    LoadingView(message: "Loading conversations...")
                } else if viewModel.conversations.isEmpty {
                    EmptyStateView(
                        icon: "bubble.left.and.bubble.right",
                        title: "No Conversations",
                        message: "Start a conversation to begin messaging with your team",
                        actionTitle: "New Conversation",
                        action: { showingNewConversation = true }
                    )
                } else {
                    conversationList
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    profileButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    newConversationButton
                }
            }
            .sheet(isPresented: $showingNewConversation) {
                NewConversationView(
                    currentUserID: authViewModel.currentUser?.id ?? ""
                )
                .environmentObject(viewModel)
            }
            .task {
                if let userID = authViewModel.currentUser?.id {
                    viewModel.startObserving(for: userID)
                }
            }
            .onDisappear {
                viewModel.stopObserving()
            }
            .errorAlert(error: Binding(
                get: { viewModel.error },
                set: { _ in viewModel.clearError() }
            ))
        }
    }
    
    private var conversationList: some View {
        List {
            ForEach(viewModel.conversations) { conversation in
                NavigationLink {
                    ChatView(
                        conversation: conversation,
                        currentUserID: authViewModel.currentUser?.id ?? ""
                    )
                } label: {
                    ConversationRowView(
                        conversation: conversation,
                        currentUserID: authViewModel.currentUser?.id ?? ""
                    )
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteConversation(conversation)
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
                await viewModel.loadConversations(for: userID)
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
    
    private var newConversationButton: some View {
        Button {
            showingNewConversation = true
        } label: {
            Image(systemName: "person.3.fill")
                .font(.title3)
        }
    }
}

#Preview {
    ConversationListView()
        .environmentObject(AuthViewModel())
}
