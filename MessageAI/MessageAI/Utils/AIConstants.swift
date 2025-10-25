//
//  AIConstants.swift
//  MessageAI
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import SwiftUI

/// Design constants for AI Chat Interface
enum AIConstants {
    
    // MARK: - Colors
    
    /// AI Assistant brand color
    static let aiBrandColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    /// AI Assistant secondary color
    static let aiSecondaryColor = Color(red: 0.9, green: 0.95, blue: 1.0)
    
    /// User message bubble color
    static let userMessageColor = Color(red: 0.0, green: 0.5, blue: 1.0)
    
    /// Assistant message bubble color
    static let assistantMessageColor = Color(red: 0.95, green: 0.95, blue: 0.95)
    
    /// System message color
    static let systemMessageColor = Color(red: 0.8, green: 0.8, blue: 0.8)
    
    /// Error message color
    static let errorColor = Color(red: 1.0, green: 0.3, blue: 0.3)
    
    /// Success message color
    static let successColor = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    /// Warning message color
    static let warningColor = Color(red: 1.0, green: 0.6, blue: 0.0)
    
    // MARK: - Fonts
    
    /// Primary message font
    static let messageFont = Font.system(size: 16, weight: .regular)
    
    /// Secondary message font (for metadata)
    static let secondaryFont = Font.system(size: 14, weight: .regular)
    
    /// Timestamp font
    static let timestampFont = Font.system(size: 12, weight: .light)
    
    /// Input field font
    static let inputFont = Font.system(size: 16, weight: .regular)
    
    /// Button font
    static let buttonFont = Font.system(size: 16, weight: .medium)
    
    // MARK: - Spacing
    
    /// Standard padding
    static let standardPadding: CGFloat = 16
    
    /// Small padding
    static let smallPadding: CGFloat = 8
    
    /// Large padding
    static let largePadding: CGFloat = 24
    
    /// Message bubble padding
    static let messagePadding: CGFloat = 12
    
    /// Input field padding
    static let inputPadding: CGFloat = 12
    
    /// Corner radius for message bubbles
    static let messageCornerRadius: CGFloat = 16
    
    /// Corner radius for input field
    static let inputCornerRadius: CGFloat = 20
    
    /// Corner radius for buttons
    static let buttonCornerRadius: CGFloat = 8
    
    // MARK: - Animation Durations
    
    /// Standard animation duration
    static let standardAnimationDuration: Double = 0.3
    
    /// Fast animation duration
    static let fastAnimationDuration: Double = 0.2
    
    /// Slow animation duration
    static let slowAnimationDuration: Double = 0.5
    
    /// Typing indicator animation duration
    static let typingAnimationDuration: Double = 1.0
    
    // MARK: - Sizes
    
    /// Message bubble max width (as percentage of screen)
    static let messageMaxWidth: CGFloat = 0.75
    
    /// Input field height
    static let inputFieldHeight: CGFloat = 44
    
    /// Send button size
    static let sendButtonSize: CGFloat = 32
    
    /// Avatar size
    static let avatarSize: CGFloat = 32
    
    /// Icon size
    static let iconSize: CGFloat = 20
    
    // MARK: - Shadows
    
    /// Message bubble shadow
    static let messageShadow = Color.black.opacity(0.1)
    
    /// Input field shadow
    static let inputShadow = Color.black.opacity(0.05)
    
    /// Button shadow
    static let buttonShadow = Color.black.opacity(0.1)
    
    // MARK: - Gradients
    
    /// AI Assistant gradient
    static let aiGradient = LinearGradient(
        colors: [aiBrandColor, aiSecondaryColor],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// User message gradient
    static let userGradient = LinearGradient(
        colors: [userMessageColor, userMessageColor.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Accessibility
    
    /// Minimum touch target size
    static let minimumTouchTarget: CGFloat = 44
    
    /// High contrast mode support
    static let highContrastMode = Color.primary
    
    /// Dynamic type support
    static let dynamicTypeRange = Font.TextStyle.caption1...Font.TextStyle.largeTitle
}
