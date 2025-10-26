//
//  SubtleCostMonitor.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// A subtle, non-intrusive cost monitor for AI usage
struct SubtleCostMonitor: View {
    @State private var totalCost: Double = 0.0
    @State private var isExpanded = false
    @State private var lastUpdate = Date()
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if isExpanded {
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Text("AI Usage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button(action: { isExpanded = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack {
                            Text("Total Cost:")
                            Text("$\(totalCost, specifier: "%.4f")")
                                .fontWeight(.medium)
                        }
                        .font(.caption)
                        
                        HStack {
                            Text("Last Update:")
                            Text(lastUpdate, style: .time)
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 2)
            } else {
                Button(action: { isExpanded = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        Text("$\(totalCost, specifier: "%.2f")")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(12)
                    .shadow(radius: 1)
                }
            }
        }
        .onAppear {
            // Simulate cost updates (in real app, this would come from AIService)
            updateCost()
        }
    }
    
    private func updateCost() {
        // Simulate cost tracking
        totalCost += Double.random(in: 0.001...0.01)
        lastUpdate = Date()
        
        // Update every 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            updateCost()
        }
    }
}

#Preview {
    SubtleCostMonitor()
        .padding()
}
