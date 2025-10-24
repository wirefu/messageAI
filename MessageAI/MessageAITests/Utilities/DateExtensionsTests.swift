//
//  DateExtensionsTests.swift
//  MessageAITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest
@testable import MessageAI

final class DateExtensionsTests: XCTestCase {
    
    // MARK: - Date Check Tests
    
    func testIsToday() {
        let now = Date()
        XCTAssertTrue(now.isToday)
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        XCTAssertFalse(tomorrow.isToday)
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        XCTAssertFalse(yesterday.isToday)
    }
    
    func testIsYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(yesterday.isYesterday)
        
        let today = Date()
        XCTAssertFalse(today.isYesterday)
        
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        XCTAssertFalse(twoDaysAgo.isYesterday)
    }
    
    func testIsThisWeek() {
        let today = Date()
        XCTAssertTrue(today.isThisWeek)
        
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        XCTAssertTrue(threeDaysAgo.isThisWeek)
        
        let nextWeek = Calendar.current.date(byAdding: .day, value: 8, to: today)!
        XCTAssertFalse(nextWeek.isThisWeek)
    }
    
    func testIsThisYear() {
        let today = Date()
        XCTAssertTrue(today.isThisYear)
        
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: today)!
        XCTAssertTrue(sixMonthsAgo.isThisYear)
        
        let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: today)!
        XCTAssertFalse(nextYear.isThisYear)
    }
    
    // MARK: - Date Arithmetic Tests
    
    func testAddingDays() {
        let date = Date()
        let tomorrow = date.adding(days: 1)
        let yesterday = date.adding(days: -1)
        
        let daysDiff1 = Calendar.current.dateComponents([.day], from: date, to: tomorrow).day
        XCTAssertEqual(daysDiff1, 1)
        
        let daysDiff2 = Calendar.current.dateComponents([.day], from: date, to: yesterday).day
        XCTAssertEqual(daysDiff2, -1)
    }
    
    func testAddingHours() {
        let date = Date()
        let future = date.adding(hours: 2)
        let past = date.adding(hours: -2)
        
        let hoursDiff1 = Calendar.current.dateComponents([.hour], from: date, to: future).hour
        XCTAssertEqual(hoursDiff1, 2)
        
        let hoursDiff2 = Calendar.current.dateComponents([.hour], from: date, to: past).hour
        XCTAssertEqual(hoursDiff2, -2)
    }
    
    func testAddingMinutes() {
        let date = Date()
        let future = date.adding(minutes: 30)
        let past = date.adding(minutes: -30)
        
        let minutesDiff1 = Calendar.current.dateComponents([.minute], from: date, to: future).minute
        XCTAssertEqual(minutesDiff1, 30)
        
        let minutesDiff2 = Calendar.current.dateComponents([.minute], from: date, to: past).minute
        XCTAssertEqual(minutesDiff2, -30)
    }
    
    // MARK: - Start/End of Day Tests
    
    func testStartOfDay() {
        let date = Date()
        let startOfDay = date.startOfDay
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
    
    func testEndOfDay() {
        let date = Date()
        let endOfDay = date.endOfDay
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: endOfDay)
        XCTAssertEqual(components.hour, 23)
        XCTAssertEqual(components.minute, 59)
        XCTAssertEqual(components.second, 59)
    }
    
    // MARK: - Formatting Tests
    
    func testDateSeparator() {
        let today = Date()
        XCTAssertEqual(today.dateSeparator, "Today")
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertEqual(yesterday.dateSeparator, "Yesterday")
    }
    
    func testTimeAgo() {
        let now = Date()
        XCTAssertEqual(now.timeAgo, "Just now")
        
        let twoMinutesAgo = Calendar.current.date(byAdding: .minute, value: -2, to: now)!
        XCTAssertEqual(twoMinutesAgo.timeAgo, "2m ago")
        
        let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: now)!
        XCTAssertEqual(twoHoursAgo.timeAgo, "2h ago")
        
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!
        XCTAssertEqual(twoDaysAgo.timeAgo, "2d ago")
    }
}

