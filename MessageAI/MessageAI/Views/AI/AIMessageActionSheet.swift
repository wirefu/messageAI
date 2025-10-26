//
//  AIMessageActionSheet.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// AI Message Action Sheet
/// Bottom sheet UI for AI message actions (Translate, Rewrite, Extract, Summarize)
struct AIMessageActionSheet: View {
    
    // MARK: - Properties
    
    let message: AIChatMessage
    let onDismiss: () -> Void
    
    @State private var selectedAction: MessageActionType?
    @State private var selectedTone: RewriteTone?
    @State private var isShowingTonePicker = false
    @State private var isShowingResult = false
    @State private var actionResult: MessageActionResult?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Action Grid
                if !isShowingTonePicker && !isShowingResult {
                    actionGridView
                }
                
                // Tone Picker
                if isShowingTonePicker {
                    tonePickerView
                }
                
                // Result View
                if isShowingResult {
                    resultView
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            Button("Cancel") {
                onDismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("Message Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            if isShowingTonePicker {
                Button("Back") {
                    isShowingTonePicker = false
                    selectedAction = nil
                }
                .foregroundColor(.blue)
            } else if isShowingResult {
                Button("Done") {
                    onDismiss()
                }
                .foregroundColor(.blue)
            } else {
                // Empty space for symmetry
                Color.clear
                    .frame(width: 60)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Action Grid View
    
    private var actionGridView: some View {
        VStack(spacing: 20) {
            Text("What would you like to do with this message?")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                // Translate Action
                ActionButton(
                    title: "Translate",
                    icon: "globe",
                    color: .blue,
                    action: {
                        selectedAction = .translate
                        isShowingTonePicker = false
                        executeAction()
                    }
                )
                
                // Rewrite Action
                ActionButton(
                    title: "Rewrite",
                    icon: "pencil",
                    color: .green,
                    action: {
                        selectedAction = .rewrite
                        isShowingTonePicker = true
                    }
                )
                
                // Extract Action
                ActionButton(
                    title: "Extract",
                    icon: "doc.text.magnifyingglass",
                    color: .orange,
                    action: {
                        selectedAction = .extract
                        isShowingTonePicker = false
                        executeAction()
                    }
                )
                
                // Summarize Action
                ActionButton(
                    title: "Summarize",
                    icon: "doc.text",
                    color: .purple,
                    action: {
                        selectedAction = .summarize
                        isShowingTonePicker = false
                        executeAction()
                    }
                )
            }
            .padding(.horizontal)
            
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Processing...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Tone Picker View
    
    private var tonePickerView: some View {
        VStack(spacing: 20) {
            Text("Choose a tone for rewriting")
                .font(.headline)
                .padding(.top)
            
            VStack(spacing: 12) {
                ForEach(RewriteTone.allCases, id: \.self) { tone in
                    ToneButton(
                        tone: tone,
                        isSelected: selectedTone == tone,
                        action: {
                            selectedTone = tone
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            Button("Rewrite Message") {
                executeAction()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedTone == nil)
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    // MARK: - Result View
    
    private var resultView: some View {
        VStack(spacing: 16) {
            if let result = actionResult {
                ResultDisplayView(
                    result: result,
                    onCopy: {
                        copyToClipboard(result)
                    },
                    onShare: {
                        shareResult(result)
                    },
                    onSend: {
                        sendResult(result)
                    }
                )
            }
        }
        .padding()
    }
    
    // MARK: - Private Methods
    
    private func executeAction() {
        guard let action = selectedAction else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await performAIMessageAction(
                    action: action,
                    message: message,
                    parameters: getActionParameters()
                )
                
                await MainActor.run {
                    self.actionResult = result
                    self.isShowingResult = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Action Execution
    
    private func performAIMessageAction(
        action: MessageActionType,
        message: AIChatMessage,
        parameters: [String: Any]
    ) async throws -> MessageActionResult {
        // For AI messages, we'll use the AIService directly with the message content
        // instead of trying to fetch from Firestore
        return try await AIService.shared.performMessageAction(
            actionType: action,
            messageId: message.id,
            conversationId: "ai-chat", // Special ID for AI chat
            parameters: parameters
        )
    }
    
    private func getActionParameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
        // Always include message content for AI chat
        parameters["messageContent"] = message.content
        
        if selectedAction == .translate {
            parameters["targetLanguage"] = "Spanish"
            parameters["sourceLanguage"] = "auto"
        } else if selectedAction == .rewrite, let tone = selectedTone {
            parameters["tone"] = tone.rawValue
        }
        
        return parameters
    }
    
    private func copyToClipboard(_ result: MessageActionResult) {
        // Pure SwiftUI approach - for now, just show a confirmation
        // In a real implementation, this would use a proper clipboard service
        print("Copy to clipboard: \(result.resultText)")
    }
    
    private func shareResult(_ result: MessageActionResult) {
        // Pure SwiftUI approach - for now, just show a confirmation
        // In a real implementation, this would use ShareLink or a proper share service
        print("Share result: \(result.resultText)")
    }
    
    private func sendResult(_ result: MessageActionResult) {
        // Pure SwiftUI approach - for now, just show a confirmation
        // In a real implementation, this would integrate with the messaging system
        print("Send result: \(result.resultText)")
    }
}

// MARK: - Supporting Views

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToneButton: View {
    let tone: RewriteTone
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tone.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(tone.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResultDisplayView: View {
    let result: MessageActionResult
    let onCopy: () -> Void
    let onShare: () -> Void
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Original Text (Collapsed)
            VStack(alignment: .leading, spacing: 8) {
                Text("Original")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(result.originalText)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Result Text (Expanded)
            VStack(alignment: .leading, spacing: 8) {
                Text(result.actionType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(result.resultText)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Copy") {
                    onCopy()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                
                Button("Share") {
                    onShare()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                
                Button("Send") {
                    onSend()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Supporting Types


// MARK: - Preview

struct AIMessageActionSheet_Previews: PreviewProvider {
    static var previews: some View {
        AIMessageActionSheet(
            message: AIChatMessage(
                id: "test-message",
                sessionID: "test-session",
                userID: "test-user",
                content: "This is a test message for the AI action sheet.",
                role: .user,
                timestamp: Date(),
                aiMetadata: nil
            ),
            onDismiss: {}
        )
    }
}
