//
//  ActionItemsView.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// View displaying action items for a conversation
struct ActionItemsView: View {
    @Environment(\.dismiss) var dismiss
    
    let conversationID: String
    
    @State private var actionItems: [ActionItem] = []
    @State private var filter: ActionItemFilter = .all
    @State private var isLoading = false
    @State private var error: AppError?
    
    private let repository = ActionItemRepository()
    
    enum ActionItemFilter: String, CaseIterable {
        case all = "All"
        case open = "Open"
        case completed = "Completed"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $filter) {
                    ForEach(ActionItemFilter.allCases, id: \.self) { filterOption in
                        Text(filterOption.rawValue).tag(filterOption)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Action Items List
                if isLoading {
                    LoadingView(message: "Loading action items...")
                } else if filteredActionItems.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "No Action Items",
                        message: filter == .all ?
                            "No action items found in this conversation" :
                            "No \(filter.rawValue.lowercased()) action items"
                    )
                } else {
                    actionItemsList
                }
            }
            .navigationTitle("Action Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadActionItems()
            }
        }
    }
    
    private var actionItemsList: some View {
        List {
            ForEach(filteredActionItems) { item in
                ActionItemRowView(
                    item: item,
                    onToggleComplete: {
                        Task {
                            await toggleComplete(item)
                        }
                    },
                    onDelete: {
                        Task {
                            await deleteItem(item)
                        }
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filteredActionItems: [ActionItem] {
        switch filter {
        case .all:
            return actionItems
        case .open:
            return actionItems.filter { !$0.isCompleted }
        case .completed:
            return actionItems.filter { $0.isCompleted }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadActionItems() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            actionItems = try await repository.getActionItems(conversationID: conversationID)
        } catch let appError as AppError {
            error = appError
        } catch {
            self.error = .firestoreError("Failed to load action items")
        }
    }
    
    // MARK: - Actions
    
    private func toggleComplete(_ item: ActionItem) async {
        do {
            try await repository.markComplete(
                id: item.id,
                conversationID: conversationID,
                isCompleted: !item.isCompleted
            )
            
            // Update local state
            if let index = actionItems.firstIndex(where: { $0.id == item.id }) {
                actionItems[index].isCompleted.toggle()
            }
        } catch {
            self.error = .firestoreError("Failed to update action item")
        }
    }
    
    private func deleteItem(_ item: ActionItem) async {
        do {
            try await repository.deleteActionItem(
                id: item.id,
                conversationID: conversationID
            )
            
            // Remove from local state
            actionItems.removeAll { $0.id == item.id }
        } catch {
            self.error = .firestoreError("Failed to delete action item")
        }
    }
}

/// Row view for a single action item
struct ActionItemRowView: View {
    let item: ActionItem
    let onToggleComplete: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.UIConfig.standardSpacing) {
            // Completion Button
            Button {
                onToggleComplete()
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Description
                Text(item.description)
                    .font(.body)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                
                // Metadata
                HStack(spacing: AppConstants.UIConfig.smallSpacing) {
                    // Assignee
                    if let assignedTo = item.assignedTo {
                        Label {
                            Text(assignedTo)
                        } icon: {
                            Image(systemName: "person.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    // Due Date
                    if let dueDate = item.dueDate {
                        Label {
                            Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(.caption)
                        .foregroundColor(item.isOverdue ? .red : .secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ActionItemsView(conversationID: "conv123")
}

#Preview("Action Item Row") {
    List {
        ActionItemRowView(
            item: ActionItem(
                id: "item1",
                conversationID: "conv1",
                messageID: "msg1",
                description: "Review the PR and provide feedback",
                assignedTo: "Alice",
                dueDate: Date().addingTimeInterval(86400),
                isCompleted: false,
                createdAt: Date()
            ),
            onToggleComplete: { print("Toggle") },
            onDelete: { print("Delete") }
        )
        
        ActionItemRowView(
            item: ActionItem(
                id: "item2",
                conversationID: "conv1",
                messageID: "msg2",
                description: "Deploy to staging",
                assignedTo: nil,
                dueDate: Date().addingTimeInterval(-86400),
                isCompleted: false,
                createdAt: Date()
            ),
            onToggleComplete: { print("Toggle") },
            onDelete: { print("Delete") }
        )
        
        ActionItemRowView(
            item: ActionItem(
                id: "item3",
                conversationID: "conv1",
                messageID: "msg3",
                description: "Write documentation",
                assignedTo: "Bob",
                dueDate: nil,
                isCompleted: true,
                createdAt: Date()
            ),
            onToggleComplete: { print("Toggle") },
            onDelete: { print("Delete") }
        )
    }
}

