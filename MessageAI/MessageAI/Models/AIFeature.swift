//
//  AIFeature.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Represents an AI feature in the app
struct AIFeature: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let demoText: String?
    let howItWorks: [String]
    let benefits: [String]
    
    init(
        id: String,
        title: String,
        subtitle: String = "",
        icon: String,
        color: Color,
        description: String,
        demoText: String? = nil,
        howItWorks: [String] = [],
        benefits: [String] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.description = description
        self.demoText = demoText
        self.howItWorks = howItWorks
        self.benefits = benefits.isEmpty ? Self.defaultBenefits(for: id) : benefits
    }
    
    private static func defaultBenefits(for id: String) -> [String] {
        switch id {
        case "summarization":
            return [
                "Save time on long conversations",
                "Quickly understand key points",
                "Never miss important decisions"
            ]
        case "clarity":
            return [
                "Improve communication effectiveness",
                "Reduce misunderstandings",
                "Professional message quality"
            ]
        case "actionItems":
            return [
                "Never lose track of tasks",
                "Automatic task extraction",
                "Ensure accountability"
            ]
        case "toneAnalysis":
            return [
                "Avoid misinterpretations",
                "Enhance professional tone",
                "Communicate with confidence"
            ]
        case "translate":
            return [
                "Break language barriers",
                "Communicate globally",
                "Context-aware translations"
            ]
        case "rewrite":
            return [
                "Refine message style",
                "Adjust tone for audience",
                "Improve message impact"
            ]
        case "extract":
            return [
                "Quickly find key information",
                "Automate data extraction",
                "Streamline information gathering"
            ]
        case "ai-chat":
            return [
                "Get instant answers and assistance",
                "Brainstorm ideas effectively",
                "Personalized AI support"
            ]
        case "proactive-suggestions":
            return [
                "Stay ahead of potential issues",
                "Receive timely, relevant advice",
                "Enhance decision-making"
            ]
        case "conversational-search":
            return [
                "Find information faster",
                "Natural language query support",
                "Access historical context easily"
            ]
        case "ai-usage-stats":
            return [
                "Monitor AI feature adoption",
                "Understand usage patterns",
                "Optimize AI integration",
                "Manage AI costs effectively"
            ]
        default:
            return []
        }
    }
}
