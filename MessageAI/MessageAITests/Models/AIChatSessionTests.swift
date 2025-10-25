//
//  AIChatSessionTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class AIChatSessionTests: XCTestCase {
    
    var aiChatSession: AIChatSession!
    var aiChatSettings: AIChatSettings!
    var aiChatStatistics: AIChatStatistics!
    
    override func setUp() {
        super.setUp()
        
        aiChatSettings = AIChatSettings(
            includeContext: true,
            enableSuggestions: true,
            enableActions: true,
            preferredModel: "gpt-4o-mini",
            responseStyle: .professional
        )
        
        aiChatStatistics = AIChatStatistics(
            totalMessages: 20,
            userMessages: 10,
            assistantMessages: 10,
            totalResponseTime: 15000,
            averageResponseTime: 750,
            suggestionsProvided: 5,
            actionsExecuted: 3
        )
        
        aiChatSession = AIChatSession(
            id: "session-123",
            userID: "user-456",
            title: "Project Discussion",
            description: "AI chat about project timelines",
            createdAt: Date(),
            lastUpdated: Date(),
            isActive: true,
            settings: aiChatSettings,
            statistics: aiChatStatistics
        )
    }
    
    override func tearDown() {
        aiChatSession = nil
        aiChatSettings = nil
        aiChatStatistics = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testAIChatSessionInitialization() {
        XCTAssertEqual(aiChatSession.id, "session-123")
        XCTAssertEqual(aiChatSession.userID, "user-456")
        XCTAssertEqual(aiChatSession.title, "Project Discussion")
        XCTAssertEqual(aiChatSession.description, "AI chat about project timelines")
        XCTAssertNotNil(aiChatSession.createdAt)
        XCTAssertNotNil(aiChatSession.lastUpdated)
        XCTAssertTrue(aiChatSession.isActive)
        XCTAssertNotNil(aiChatSession.settings)
        XCTAssertNotNil(aiChatSession.statistics)
    }
    
    func testAIChatSessionWithoutOptionalFields() {
        let session = AIChatSession(
            id: "session-456",
            userID: "user-789",
            title: "Simple Chat",
            description: nil,
            createdAt: Date(),
            lastUpdated: Date(),
            isActive: false,
            settings: aiChatSettings,
            statistics: nil
        )
        
        XCTAssertEqual(session.id, "session-456")
        XCTAssertEqual(session.userID, "user-789")
        XCTAssertEqual(session.title, "Simple Chat")
        XCTAssertNil(session.description)
        XCTAssertFalse(session.isActive)
        XCTAssertNil(session.statistics)
    }
    
    // MARK: - AIChatSettings Tests
    
    func testAIChatSettingsInitialization() {
        XCTAssertTrue(aiChatSettings.includeContext)
        XCTAssertTrue(aiChatSettings.enableSuggestions)
        XCTAssertTrue(aiChatSettings.enableActions)
        XCTAssertEqual(aiChatSettings.preferredModel, "gpt-4o-mini")
        XCTAssertEqual(aiChatSettings.responseStyle, .professional)
    }
    
    func testAIChatResponseStyleCases() {
        XCTAssertEqual(AIChatResponseStyle.professional.rawValue, "professional")
        XCTAssertEqual(AIChatResponseStyle.casual.rawValue, "casual")
        XCTAssertEqual(AIChatResponseStyle.technical.rawValue, "technical")
        XCTAssertEqual(AIChatResponseStyle.friendly.rawValue, "friendly")
        
        let allCases = AIChatResponseStyle.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.professional))
        XCTAssertTrue(allCases.contains(.casual))
        XCTAssertTrue(allCases.contains(.technical))
        XCTAssertTrue(allCases.contains(.friendly))
    }
    
    // MARK: - AIChatStatistics Tests
    
    func testAIChatStatisticsInitialization() {
        XCTAssertEqual(aiChatStatistics.totalMessages, 20)
        XCTAssertEqual(aiChatStatistics.userMessages, 10)
        XCTAssertEqual(aiChatStatistics.assistantMessages, 10)
        XCTAssertEqual(aiChatStatistics.totalResponseTime, 15000)
        XCTAssertEqual(aiChatStatistics.averageResponseTime, 750)
        XCTAssertEqual(aiChatStatistics.suggestionsProvided, 5)
        XCTAssertEqual(aiChatStatistics.actionsExecuted, 3)
    }
    
    func testAIChatStatisticsHasStatistics() {
        XCTAssertTrue(aiChatStatistics.hasStatistics)
        
        let emptyStatistics = AIChatStatistics(
            totalMessages: 0,
            userMessages: 0,
            assistantMessages: 0,
            totalResponseTime: 0,
            averageResponseTime: 0,
            suggestionsProvided: 0,
            actionsExecuted: 0
        )
        
        XCTAssertFalse(emptyStatistics.hasStatistics)
    }
    
    func testAIChatStatisticsAverageResponseTimeSeconds() {
        XCTAssertEqual(aiChatStatistics.averageResponseTimeSeconds, 0.75)
    }
    
    func testAIChatStatisticsUserMessagePercentage() {
        XCTAssertEqual(aiChatStatistics.userMessagePercentage, 50.0)
    }
    
    func testAIChatStatisticsAssistantMessagePercentage() {
        XCTAssertEqual(aiChatStatistics.assistantMessagePercentage, 50.0)
    }
    
    // MARK: - Helper Tests
    
    func testHasMessages() {
        XCTAssertTrue(aiChatSession.hasMessages)
        
        let sessionWithoutMessages = AIChatSession(
            id: "session-456",
            userID: "user-789",
            title: "Empty Chat",
            description: nil,
            createdAt: Date(),
            lastUpdated: Date(),
            isActive: true,
            settings: aiChatSettings,
            statistics: AIChatStatistics(
                totalMessages: 0,
                userMessages: 0,
                assistantMessages: 0,
                totalResponseTime: 0,
                averageResponseTime: 0,
                suggestionsProvided: 0,
                actionsExecuted: 0
            )
        )
        
        XCTAssertFalse(sessionWithoutMessages.hasMessages)
    }
    
    func testIsRecent() {
        let recentSession = AIChatSession(
            id: "session-456",
            userID: "user-789",
            title: "Recent Chat",
            description: nil,
            createdAt: Date(),
            lastUpdated: Date(),
            isActive: true,
            settings: aiChatSettings,
            statistics: nil
        )
        
        XCTAssertTrue(recentSession.isRecent)
        
        let oldSession = AIChatSession(
            id: "session-789",
            userID: "user-123",
            title: "Old Chat",
            description: nil,
            createdAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            lastUpdated: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            isActive: true,
            settings: aiChatSettings,
            statistics: nil
        )
        
        XCTAssertFalse(oldSession.isRecent)
    }
    
    func testDurationMinutes() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 hour later
        
        let session = AIChatSession(
            id: "session-456",
            userID: "user-789",
            title: "Test Chat",
            description: nil,
            createdAt: startDate,
            lastUpdated: endDate,
            isActive: true,
            settings: aiChatSettings,
            statistics: nil
        )
        
        XCTAssertEqual(session.durationMinutes, 60)
    }
    
    // MARK: - Codable Tests
    
    func testAIChatSessionCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(aiChatSession)
            let decodedSession = try decoder.decode(AIChatSession.self, from: data)
            
            XCTAssertEqual(decodedSession.id, aiChatSession.id)
            XCTAssertEqual(decodedSession.userID, aiChatSession.userID)
            XCTAssertEqual(decodedSession.title, aiChatSession.title)
            XCTAssertEqual(decodedSession.description, aiChatSession.description)
            XCTAssertEqual(decodedSession.isActive, aiChatSession.isActive)
        } catch {
            XCTFail("Failed to encode/decode AIChatSession: \(error)")
        }
    }
    
    func testAIChatSettingsCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(aiChatSettings)
            let decodedSettings = try decoder.decode(AIChatSettings.self, from: data)
            
            XCTAssertEqual(decodedSettings.includeContext, aiChatSettings.includeContext)
            XCTAssertEqual(decodedSettings.enableSuggestions, aiChatSettings.enableSuggestions)
            XCTAssertEqual(decodedSettings.enableActions, aiChatSettings.enableActions)
            XCTAssertEqual(decodedSettings.preferredModel, aiChatSettings.preferredModel)
            XCTAssertEqual(decodedSettings.responseStyle, aiChatSettings.responseStyle)
        } catch {
            XCTFail("Failed to encode/decode AIChatSettings: \(error)")
        }
    }
    
    func testAIChatStatisticsCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(aiChatStatistics)
            let decodedStatistics = try decoder.decode(AIChatStatistics.self, from: data)
            
            XCTAssertEqual(decodedStatistics.totalMessages, aiChatStatistics.totalMessages)
            XCTAssertEqual(decodedStatistics.userMessages, aiChatStatistics.userMessages)
            XCTAssertEqual(decodedStatistics.assistantMessages, aiChatStatistics.assistantMessages)
            XCTAssertEqual(decodedStatistics.totalResponseTime, aiChatStatistics.totalResponseTime)
            XCTAssertEqual(decodedStatistics.averageResponseTime, aiChatStatistics.averageResponseTime)
            XCTAssertEqual(decodedStatistics.suggestionsProvided, aiChatStatistics.suggestionsProvided)
            XCTAssertEqual(decodedStatistics.actionsExecuted, aiChatStatistics.actionsExecuted)
        } catch {
            XCTFail("Failed to encode/decode AIChatStatistics: \(error)")
        }
    }
    
    // MARK: - Equatable Tests
    
    func testAIChatSessionEquatable() {
        let session1 = AIChatSession(
            id: "session-123",
            userID: "user-456",
            title: "Test Chat",
            description: nil,
            createdAt: Date(),
            lastUpdated: Date(),
            isActive: true,
            settings: aiChatSettings,
            statistics: nil
        )
        
        let session2 = AIChatSession(
            id: "session-123",
            userID: "user-456",
            title: "Test Chat",
            description: nil,
            createdAt: session1.createdAt,
            lastUpdated: session1.lastUpdated,
            isActive: true,
            settings: aiChatSettings,
            statistics: nil
        )
        
        XCTAssertEqual(session1, session2)
    }
    
    func testAIChatSettingsEquatable() {
        let settings1 = AIChatSettings(
            includeContext: true,
            enableSuggestions: true,
            enableActions: true,
            preferredModel: "gpt-4o-mini",
            responseStyle: .professional
        )
        
        let settings2 = AIChatSettings(
            includeContext: true,
            enableSuggestions: true,
            enableActions: true,
            preferredModel: "gpt-4o-mini",
            responseStyle: .professional
        )
        
        XCTAssertEqual(settings1, settings2)
    }
    
    func testAIChatStatisticsEquatable() {
        let statistics1 = AIChatStatistics(
            totalMessages: 20,
            userMessages: 10,
            assistantMessages: 10,
            totalResponseTime: 15000,
            averageResponseTime: 750,
            suggestionsProvided: 5,
            actionsExecuted: 3
        )
        
        let statistics2 = AIChatStatistics(
            totalMessages: 20,
            userMessages: 10,
            assistantMessages: 10,
            totalResponseTime: 15000,
            averageResponseTime: 750,
            suggestionsProvided: 5,
            actionsExecuted: 3
        )
        
        XCTAssertEqual(statistics1, statistics2)
    }
}
