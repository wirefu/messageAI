# 🧪 Test Database Setup Guide

## Overview
This guide explains how to set up a proper test database environment for UI tests using Firebase emulators.

## Why We Need Test Databases

### Problems with Production Database Testing
- **Data Conflicts**: Multiple tests creating users with same email
- **Authentication Issues**: Real Firebase Auth has rate limits and security rules
- **Data Persistence**: Tests leave behind data that affects other tests
- **Cost**: Production Firebase usage costs money
- **Speed**: Emulators are faster than production services

### Benefits of Emulator Testing
- ✅ **Isolated Environment**: Each test run starts fresh
- ✅ **No Rate Limits**: Test as much as you want
- ✅ **Fast Execution**: Local emulators are much faster
- ✅ **No Costs**: Free to run unlimited tests
- ✅ **Predictable State**: Clean database for each test

## Setup Instructions

### 1. Start Firebase Emulators

```bash
# From project root
./scripts/start-emulators.sh

# Or manually:
firebase emulators:start --only auth,firestore,functions,storage
```

### 2. Verify Emulators Are Running

Visit: http://localhost:4000 (Emulator UI)

You should see:
- ✅ Auth Emulator (port 9099)
- ✅ Firestore Emulator (port 8080) 
- ✅ Functions Emulator (port 5001)
- ✅ Storage Emulator (port 9199)

### 3. Run UI Tests

```bash
# Run all UI tests
xcodebuild test -scheme MessageAI -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:MessageAIUITests

# Run specific test
xcodebuild test -scheme MessageAI -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:MessageAIUITests/AuthenticationUITests/testCompleteSignUpFlow
```

## Test Database Architecture

### TestFirebaseConfig.swift
- **Purpose**: Configures Firebase to use emulators
- **Features**:
  - Automatic emulator configuration
  - Test data cleanup between tests
  - Test user creation and management
  - Sample data generation

### UITestSetup.swift
- **Purpose**: Base class for all UI tests
- **Features**:
  - Automatic setup/teardown
  - Test user management
  - UI interaction helpers
  - Debug utilities

### Test Data Flow
```
1. Test Starts
   ↓
2. Clear All Emulator Data
   ↓
3. Create Test User
   ↓
4. Generate Sample Data
   ↓
5. Run UI Test
   ↓
6. Test Ends
   ↓
7. Clean Up Data
```

## Test User Management

### Automatic User Creation
```swift
// Creates test user automatically
try await createAndSignInTestUser()
```

### Test Credentials
- **Email**: `uitest@example.com`
- **Password**: `testpassword123`
- **Display Name**: `UI Test User`

### User Lifecycle
1. **Setup**: Create fresh test user
2. **Test**: Use user for UI interactions
3. **Teardown**: Delete user and all data

## Sample Test Data

### Conversations
- **Title**: "Test Conversation"
- **Participants**: Test user only
- **Status**: Active

### Messages
- 4 sample messages
- Timestamps: 1 minute apart
- Status: All sent

## Debugging UI Tests

### Common Issues

#### 1. Emulators Not Running
```
Error: Firebase emulators are not running
Solution: Run ./scripts/start-emulators.sh
```

#### 2. Navigation Timeout
```
Error: Should navigate to Messages screen
Solution: Check if authentication flow is working
```

#### 3. Element Not Found
```
Error: Element should exist
Solution: Use printUIHierarchy() to debug
```

### Debug Helpers

#### Print UI Hierarchy
```swift
printUIHierarchy() // Shows current screen elements
```

#### Take Screenshots
```swift
takeScreenshot(name: "signup-form") // Captures current screen
```

#### Wait for Elements
```swift
waitForElement(app.buttons["Login"]) // Waits for element to appear
```

## Best Practices

### 1. Test Isolation
- Each test starts with clean database
- No shared state between tests
- Independent test execution

### 2. Data Cleanup
- Always clean up after tests
- Don't leave test data behind
- Use try/catch for cleanup operations

### 3. Error Handling
- Graceful handling of emulator issues
- Clear error messages for debugging
- Fallback strategies for test failures

### 4. Performance
- Use emulators for speed
- Minimize test data size
- Parallel test execution when possible

## Troubleshooting

### Emulator Connection Issues
```bash
# Check if emulators are running
curl http://localhost:8080

# Restart emulators
firebase emulators:start --only auth,firestore,functions,storage
```

### Test Data Issues
```swift
// Clear data manually
try await TestFirebaseConfig.clearTestData()

// Check emulator status
let isRunning = await TestFirebaseConfig.checkEmulatorStatus()
```

### Authentication Issues
```swift
// Sign out and create fresh user
try await TestFirebaseConfig.signOutUser()
try await createAndSignInTestUser()
```

## Next Steps

1. **Start Emulators**: Run `./scripts/start-emulators.sh`
2. **Run Tests**: Execute UI tests with emulator setup
3. **Debug Issues**: Use debug helpers to troubleshoot
4. **Extend Tests**: Add more test scenarios
5. **Optimize**: Improve test performance and reliability

## Resources

- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [XCTest UI Testing](https://developer.apple.com/documentation/xctest/xcuitest)
- [Firebase Auth Emulator](https://firebase.google.com/docs/emulator-suite/connect_auth)
- [Firestore Emulator](https://firebase.google.com/docs/emulator-suite/connect_firestore)
