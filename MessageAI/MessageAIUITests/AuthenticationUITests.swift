//
//  AuthenticationUITests.swift
//  MessageAIUITests
//
//  Created by Gauntlet AI Team
//  Copyright © 2025 Gauntlet AI. All rights reserved.
//

import XCTest

final class AuthenticationUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testLoginViewDisplays() {
        XCTAssertTrue(app.staticTexts["Welcome Back"].exists)
        XCTAssertTrue(app.staticTexts["Sign in to continue messaging"].exists)
        XCTAssertTrue(app.buttons["Login"].exists)
    }
    
    func testNavigateToSignUp() {
        app.buttons["Sign Up"].tap()
        XCTAssertTrue(app.staticTexts["Create Account"].exists)
    }
    
    func testNavigateBackToLogin() {
        app.buttons["Sign Up"].tap()
        app.buttons["Login"].tap()
        XCTAssertTrue(app.staticTexts["Welcome Back"].exists)
    }
    
    func testSignUpViewDisplays() {
        app.buttons["Sign Up"].tap()
        XCTAssertTrue(app.staticTexts["Create Account"].exists)
        XCTAssertTrue(app.staticTexts["Join your team on MessengerAI"].exists)
        XCTAssertTrue(app.buttons["Create Account"].exists)
    }
    
    func testLoginButtonDisabledWithEmptyFields() {
        let loginButton = app.buttons["Login"]
        XCTAssertFalse(loginButton.isEnabled)
    }
}

