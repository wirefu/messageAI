//
//  EnhancedAIChatView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Enhanced AI Chat Interface with improved visual design and user experience
struct EnhancedAIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showingMessageActionSheet = false
    @State private var selectedMessageForAction: AIChatMessage?
    @State private var showingAIFeatures = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced header with AI status
                enhancedHeader
                
                // Messages area with improved design
                messagesArea
                
                // Enhanced input area
                enhancedInputArea
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAIFeatures = true
                    } label: {
                        Image(systemName: "sparkles")
                            .foregroundColor(AIConstants.aiBrandColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Cost Monitor Button (only on AI Assistant screen)
                        #if DEBUG
                        SubtleCostMonitor()
                        #endif
                        
                        Button("Clear") {
                            viewModel.clearSession()
                        }
                        .foregroundColor(AIConstants.aiBrandColor)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showingMessageActionSheet) {
                if let message = selectedMessageForAction {
                    AIMessageActionSheet(
                        message: message,
                        isPresented: $showingMessageActionSheet
                    )
                }
            }
            .sheet(isPresented: $showingAIFeatures) {
                AIFeatureOverview()
            }
        }
    }
    
    // MARK: - Enhanced Header
    
    private var enhancedHeader: some View {
        VStack(spacing: 8) {
            // AI Status indicator
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    
                    Text("AI Assistant Active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick stats
                HStack(spacing: 16) {
                    StatBadge(
                        icon: "message",
                        value: "\(viewModel.messages.count)",
                        label: "Messages"
                    )
                    
                    StatBadge(
                        icon: "brain.head.profile",
                        value: "GPT-4",
                        label: "Model"
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            Divider()
        }
    }
    
    // MARK: - Messages Area
    
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Welcome message for new sessions
                    if viewModel.messages.isEmpty {
                        welcomeMessage
                    }
                    
                    // Messages
                    ForEach(viewModel.messages) { message in
                        EnhancedAIMessageBubbleView(
                            message: message,
                            onActionTap: {
                                selectedMessageForAction = message
                                showingMessageActionSheet = true
                            }
                        )
                        .id(message.id)
                    }
                    
                    // Loading indicator
                    if viewModel.isLoading {
                        loadingIndicator
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Enhanced Input Area
    
    private var enhancedInputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 12) {
                // Quick suggestions
                if !viewModel.suggestions.isEmpty {
                    quickSuggestions
                }
                
                // Input area
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("Ask AI anything...", text: $viewModel.messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                        .focused($isInputFocused)
                        .disabled(viewModel.isLoading)
                    
                    Button(action: sendMessage) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.messageText.isEmpty ? .gray : AIConstants.aiBrandColor)
                        }
                    }
                    .disabled(viewModel.messageText.isEmpty || viewModel.isLoading)
                    .frame(width: 32, height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Supporting Views
    
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(AIConstants.aiBrandColor)
            
            Text("Welcome to AI Assistant")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("I'm here to help you with questions, brainstorming, and intelligent assistance. What would you like to know?")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Quick action buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    title: "Help with Code",
                    icon: "chevron.left.forwardslash.chevron.right",
                    color: .blue
                ) {
                    viewModel.messageText = "Can you help me with a coding problem?"
                }
                
                QuickActionButton(
                    title: "Brainstorm Ideas",
                    icon: "lightbulb",
                    color: .yellow
                ) {
                    viewModel.messageText = "Let's brainstorm some creative ideas"
                }
                
                QuickActionButton(
                    title: "Explain Concept",
                    icon: "questionmark.circle",
                    color: .green
                ) {
                    viewModel.messageText = "Can you explain this concept to me?"
                }
                
                QuickActionButton(
                    title: "Write Content",
                    icon: "pencil",
                    color: .purple
                ) {
                    viewModel.messageText = "Help me write professional content"
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var loadingIndicator: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            
            Text("AI is thinking...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private var quickSuggestions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                    Button(suggestion) {
                        viewModel.messageText = suggestion
                        sendMessage()
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AIConstants.aiBrandColor.opacity(0.1))
                    )
                    .foregroundColor(AIConstants.aiBrandColor)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let textToSend = viewModel.messageText
        viewModel.messageText = ""
        
        Task {
            await viewModel.sendMessage(content: textToSend)
        }
    }
}

// MARK: - Supporting Views

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct EnhancedAIMessageBubbleView: View {
    let message: AIChatMessage
    let onActionTap: () -> Void
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AIConstants.aiBrandColor)
                        )
                    
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(AIConstants.aiBrandColor)
                            .padding(.top, 2)
                        
                        Text(message.content)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            onActionTap()
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview

struct EnhancedAIChatView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedAIChatView()
    }
}
