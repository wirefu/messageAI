//
//  AIActionView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// View for executing AI actions
struct AIActionView: View {
    @Environment(\.dismiss) var dismiss
    
    let action: AIChatAction
    let messageContent: String
    let onActionExecuted: (Any) -> Void
    
    @State private var isLoading = false
    @State private var result: Any?
    @State private var error: AppError?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Action header
                VStack(spacing: 12) {
                    Image(systemName: actionIcon)
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text(action.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(action.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Content to process
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content to process:")
                        .font(.headline)
                    
                    Text(messageContent)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Result or loading
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Processing...")
                            .font(.headline)
                        Text("This may take a few seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let result = result {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Result:")
                            .font(.headline)
                        
                        ScrollView {
                            Text(formatResult(result))
                                .font(.body)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                } else if let error = error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                        
                        Text("Error")
                            .font(.headline)
                        
                        Text(error.localizedDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("AI Action")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if result != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            onActionExecuted(result!)
                            dismiss()
                        }
                    }
                }
            }
            .task {
                await executeAction()
            }
        }
    }
    
    private var actionIcon: String {
        switch action.id {
        case "translate":
            return "globe"
        case "summarize":
            return "doc.text"
        case "extract_action_items":
            return "checklist"
        case "rewrite":
            return "pencil"
        case "analyze_tone":
            return "face.smiling"
        default:
            return "bolt"
        }
    }
    
    private func executeAction() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Simulate action execution
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Mock result based on action type
            switch action.id {
            case "translate":
                result = "Translated text: \(messageContent) → [Spanish translation would appear here]"
            case "summarize":
                result = "Summary: This message discusses \(messageContent.prefix(50))... and contains key points about the topic."
            case "extract_action_items":
                result = [
                    "Action Item 1: Follow up on the discussion",
                    "Action Item 2: Review the proposed changes",
                    "Action Item 3: Schedule a meeting"
                ]
            case "rewrite":
                result = "Rewritten version: \(messageContent) → [Improved version would appear here]"
            case "analyze_tone":
                result = "Tone Analysis: Professional, constructive, and collaborative. No concerns detected."
            default:
                result = "Action executed successfully: \(action.name)"
            }
        } catch {
            self.error = .networkUnavailable
        }
    }
    
    private func formatResult(_ result: Any) -> String {
        if let array = result as? [String] {
            return array.joined(separator: "\n")
        } else if let string = result as? String {
            return string
        } else {
            return "\(result)"
        }
    }
}
