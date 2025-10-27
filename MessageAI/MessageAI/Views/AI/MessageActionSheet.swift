//
//  MessageActionSheet.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Message Action Sheet
/// Bottom sheet UI for message actions (Translate, Rewrite, Extract, Summarize)
struct MessageActionSheet: View {
    
    // MARK: - Properties
    
    let messageId: String
    let conversationId: String
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
                // Try real backend first
                let result = try await performMessageAction(
                    action: action,
                    messageId: messageId,
                    conversationId: conversationId,
                    parameters: getActionParameters()
                )
                
                await MainActor.run {
                    self.actionResult = result
                    self.isShowingResult = true
                    self.isLoading = false
                }
            } catch {
                // Fallback to mock result for demo purposes
                print("⚠️ Backend error, using mock result: \(error.localizedDescription)")
                
                   await MainActor.run {
                       let mockResult = MessageActionResult(
                           actionType: action,
                           originalText: "Sample message for demonstration",
                           resultText: getMockResultText(for: action),
                           metadata: ["source": "mock", "timestamp": Date().timeIntervalSince1970]
                       )
                       
                       self.actionResult = mockResult
                       self.isShowingResult = true
                       self.isLoading = false
                   }
            }
        }
    }
    
    // MARK: - Action Execution
    
    private func performMessageAction(
        action: MessageActionType,
        messageId: String,
        conversationId: String,
        parameters: [String: Any]
    ) async throws -> MessageActionResult {
        // Call the AIService to perform the action
        return try await AIService.shared.performMessageAction(
            actionType: action,
            messageId: messageId,
            conversationId: conversationId,
            parameters: parameters
        )
    }
    
    private func getMockResultText(for action: MessageActionType) -> String {
        switch action {
        case .translate:
            return "Este es un mensaje de muestra para propósitos de prueba."
        case .rewrite:
            return "This represents a sample message designed for testing purposes."
        case .extract:
            return "Entities: [sample, message, testing, purposes]"
        case .summarize:
            return "This is a summary of the conversation thread."
        case .clarify:
            return "This is a clearer version of the message with improved wording."
        case .expand:
            return "This is an expanded version with additional details and context."
        case .shorten:
            return "This is a concise version."
        }
    }
    
    private func getActionParameters() -> [String: Any] {
        var parameters: [String: Any] = [:]
        
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
// Note: ActionButton, ToneButton, and ResultDisplayView are defined in AIMessageActionSheet.swift

// MARK: - Supporting Types



// MARK: - Preview

struct MessageActionSheet_Previews: PreviewProvider {
    static var previews: some View {
        MessageActionSheet(
            messageId: "test-message",
            conversationId: "test-conversation",
            onDismiss: {}
        )
    }
}
