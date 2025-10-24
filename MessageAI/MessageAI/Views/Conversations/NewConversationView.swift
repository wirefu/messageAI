//
//  NewConversationView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// View for creating a new conversation
struct NewConversationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var conversationViewModel: ConversationListViewModel
    
    let currentUserID: String
    var onConversationCreated: (String) -> Void
    
    @State private var searchText = ""
    @State private var availableUsers: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let userRepository = UserRepository()
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    LoadingView(message: "Loading users...")
                } else if availableUsers.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Users Found",
                        message: "No other users available to start a conversation with"
                    )
                } else {
                    userList
                }
            }
            .navigationTitle("New Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search users")
            .task {
                await loadUsers()
            }
        }
    }
    
    private var userList: some View {
        List(filteredUsers) { user in
            Button {
                Task {
                    await createConversation(with: user)
                }
            } label: {
                HStack(spacing: AppConstants.UIConfig.standardSpacing) {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Text(user.displayName.prefix(1))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .overlay(alignment: .bottomTrailing) {
                            if user.isOnline {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 12, height: 12)
                                    .overlay {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    }
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.displayName)
                            .font(.headline)
                        
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if user.isOnline {
                            Text("Online")
                                .font(.caption2)
                                .foregroundColor(.green)
                        } else {
                            Text("Last seen \(user.lastSeen.timeAgo())")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return availableUsers
        }
        return availableUsers.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func loadUsers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            availableUsers = try await userRepository.getAllUsers(excludingUserID: currentUserID)
        } catch {
            errorMessage = "Failed to load users: \(error.localizedDescription)"
            availableUsers = []
        }
    }
    
    private func createConversation(with user: User) async {
        do {
            let conversationID = try await conversationViewModel.createNewConversation(
                currentUserID: currentUserID,
                otherUserID: user.id
            )
            dismiss()
            onConversationCreated(conversationID)
        } catch {
            // Error handled by ViewModel
        }
    }
}

#Preview {
    NewConversationView(currentUserID: "user123") { _ in
        print("Conversation created")
    }
    .environmentObject(ConversationListViewModel())
}
