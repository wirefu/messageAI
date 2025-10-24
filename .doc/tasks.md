# MessengerAI - Development Task List
## PR-Based Checklist with File Structure

**Project:** MessengerAI MVP  
**Tech Stack:** Swift + SwiftUI + Firebase + OpenAI  
**Architecture:** MVVM with Repository Pattern  
**Tools:** Cursor + Sweetpad + XcodeGen + SwiftLint + InjectionNext  
**Total PRs:** 27  
**Timeline:** 3 Weeks (21 Days)  
**Last Updated:** October 23, 2025

---

## 🛠️ Development Tooling (Current Setup)

**Build System:**
- **XcodeGen** (v2.44.1) - Generates `.xcodeproj` from `project.yml`
- **Sweetpad** - Cursor extension for building without Xcode
- **Swift Package Manager** - Dependency management (configured via XcodeGen)

**Code Quality:**
- **SwiftLint** (v0.61.0) - Enforces style and catches errors
- **Custom Rules** - @MainActor for ViewModels, Firebase cleanup checks

**Development Workflow:**
- **Cursor** - AI-powered editor with 8 custom `.mdc` rule files
- **InjectionNext** - Hot reload for instant UI updates
- **Memory Bank** - 6 markdown files for project context

**Backend:**
- **Firebase CLI** (v14.21.0) - Deploy functions, rules, emulators
- **Node.js** (v22.14.0) - Cloud Functions runtime
- **OpenAI** - Via Cloud Functions (3 deployed: summarize, clarity, actionItems)

**Commands:**
```bash
npm run xcode:generate     # Generate Xcode project
npm run build              # Build via xcodebuild (or use Sweetpad Cmd+Shift+B)
npm run lint:fix           # Auto-fix SwiftLint issues
npm run functions:deploy   # Deploy Cloud Functions
```

---

## 📁 Project File Structure

```
MessengerAI/
├── MessengerAI/
│   ├── App/
│   │   ├── MessengerAIApp.swift                 # App entry point
│   │   └── AppDelegate.swift                    # Firebase initialization
│   │
│   ├── Models/
│   │   ├── User.swift                           # User data model
│   │   ├── Conversation.swift                   # Conversation model
│   │   ├── Message.swift                        # Message model
│   │   ├── MessageStatus.swift                  # Message status enum
│   │   ├── ActionItem.swift                     # Action item model
│   │   ├── ConversationSummary.swift           # Summary model
│   │   └── AISuggestion.swift                  # AI suggestion models
│   │
│   ├── Views/
│   │   ├── Authentication/
│   │   │   ├── LoginView.swift
│   │   │   ├── SignUpView.swift
│   │   │   └── AuthContainerView.swift
│   │   │
│   │   ├── Conversations/
│   │   │   ├── ConversationListView.swift
│   │   │   ├── ConversationRowView.swift
│   │   │   └── NewConversationView.swift
│   │   │
│   │   ├── Chat/
│   │   │   ├── ChatView.swift
│   │   │   ├── MessageBubbleView.swift
│   │   │   ├── MessageInputView.swift
│   │   │   ├── TypingIndicatorView.swift
│   │   │   └── MessageStatusView.swift
│   │   │
│   │   ├── AI/
│   │   │   ├── SummaryView.swift
│   │   │   ├── ClaritySuggestionView.swift
│   │   │   ├── ActionItemsView.swift
│   │   │   └── ToneSuggestionView.swift
│   │   │
│   │   └── Components/
│   │       ├── LoadingView.swift
│   │       ├── ErrorView.swift
│   │       └── EmptyStateView.swift
│   │
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift
│   │   ├── ConversationListViewModel.swift
│   │   ├── ChatViewModel.swift
│   │   ├── MessageInputViewModel.swift
│   │   └── AIFeaturesViewModel.swift
│   │
│   ├── Services/
│   │   ├── AuthenticationService.swift
│   │   ├── NetworkMonitor.swift
│   │   ├── OfflineQueueService.swift
│   │   ├── AIService.swift
│   │   └── NotificationService.swift
│   │
│   ├── Repositories/
│   │   ├── UserRepository.swift
│   │   ├── ConversationRepository.swift
│   │   ├── MessageRepository.swift
│   │   ├── ActionItemRepository.swift
│   │   └── SummaryRepository.swift
│   │
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── Date+Extensions.swift
│   │   │   ├── String+Extensions.swift
│   │   │   └── View+Extensions.swift
│   │   │
│   │   ├── Helpers/
│   │   │   ├── UserDefaultsManager.swift
│   │   │   ├── KeychainManager.swift
│   │   │   └── DateFormatter+Shared.swift
│   │   │
│   │   └── Constants/
│   │       ├── FirebaseConstants.swift
│   │       └── AppConstants.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   ├── GoogleService-Info.plist
│   │   └── Info.plist
│   │
│   └── Configuration/
│       └── FirebaseConfig.swift
│
├── MessengerAITests/
│   ├── AuthenticationTests.swift
│   ├── MessageRepositoryTests.swift
│   ├── ConversationRepositoryTests.swift
│   ├── OfflineQueueTests.swift
│   └── ViewModelTests.swift
│
├── MessengerAIUITests/
│   ├── AuthenticationUITests.swift
│   ├── MessagingUITests.swift
│   └── AIFeaturesUITests.swift
│
├── CloudFunctions/
│   ├── functions/
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── summarization.ts
│   │   │   ├── clarity.ts
│   │   │   ├── actionItems.ts
│   │   │   └── toneAnalysis.ts
│   │   │
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── firestore.rules
│
├── project.yml                                   # XcodeGen project spec
├── .swiftlint.yml                                # Code quality rules
└── README.md
```

---

## 📊 Current Status

**Phase 0:** ✅ COMPLETE (100%)  
**Phase 1:** 🎯 Ready to Start (0%)  
**Phase 2:** ⏳ Pending (0%)  
**Phase 3:** ⏳ Pending (0%)

**Infrastructure:**
- ✅ Firebase configured (Firestore, Auth, Functions, Storage)
- ✅ Cloud Functions deployed (3 AI functions with OpenAI)
- ✅ Development tools installed (XcodeGen, SwiftLint, Firebase CLI)
- ✅ Code quality baseline (0 SwiftLint violations)
- ✅ Hot reload configured (InjectionNext)
- ✅ Cursor AI rules (8 modular .mdc files)
- ✅ Memory Bank system (6 core files)

**Code:**
- ✅ App entry points (AppDelegate, MessengerAIApp)
- ⏳ Models (0 of 7)
- ⏳ Views (0 of 15+)
- ⏳ ViewModels (0 of 5)
- ⏳ Repositories (0 of 5)
- ⏳ Services (0 of 5)

**Next:** PR #2 - Core Architecture & Constants

---

## 🎯 Phase 0: Project Setup & Foundation ✅ COMPLETE

### PR #1: Initial Project Setup ✅ COMPLETE
**Branch:** `feature/project-setup`  
**Description:** Create project structure, configure Firebase, install dev tools  
**Timeline:** Day 1  
**Status:** ✅ Complete

**Tasks:**
- [x] Create project structure with XcodeGen
  - Files: `MessengerAIApp.swift`, `AppDelegate.swift`, `ContentView.swift`
- [x] Set up folder structure (Models, Views, ViewModels, Services, Repositories, Utilities)
  - All directories created and ready
- [x] Create Firebase project in console
  - Project ID: `messengerai-7300e`
  - Downloaded `GoogleService-Info.plist`
- [x] Add Firebase SDK via XcodeGen
  - Configured in `project.yml` with Firebase dependencies
  - Dependencies: FirebaseAuth, Firestore, Functions, Storage, Analytics
- [x] Install development tools
  - XcodeGen v2.44.1 (project generation)
  - SwiftLint v0.61.0 (code quality)
  - Firebase CLI v14.21.0 (backend)
  - InjectionNext (hot reload)
- [x] Install Firebase CLI locally
  - Run: `npm install firebase-tools --save-dev`
- [x] Configure `GoogleService-Info.plist` in project
  - Placed in `MessageAI/MessageAI/` and root
- [x] Create `AppDelegate.swift` with Firebase initialization
  - File: `App/AppDelegate.swift` ✅
  - Offline persistence enabled
- [x] Configure `.gitignore` file
  - Excludes generated files, node_modules
- [x] Set up Cursor workspace (`.vscode/`)
  - Keyboard shortcuts for Sweetpad
  - Build tasks configured
- [x] Create modular cursor rules (`.cursor/rules/*.mdc`)
  - 8 specialized rule files
- [x] Create Memory Bank system (`memory-bank/*.md`)
  - 7 documentation files (6 core + structure review)
- [x] Deploy Firebase backend
  - Firestore rules deployed
  - Storage rules deployed
  - Cloud Functions deployed (3 AI functions)

**Files Created:**
- `MessengerAI/App/MessengerAIApp.swift` ✅
- `MessengerAI/App/AppDelegate.swift` ✅
- `MessengerAI/Resources/GoogleService-Info.plist` ✅
- `MessengerAI/Resources/Info.plist` ✅
- `project.yml` ✅ (XcodeGen spec)
- `.swiftlint.yml` ✅
- `.gitignore` ✅
- `README.md` ✅
- `.cursor/rules/*.mdc` ✅ (8 modular rules)
- `memory-bank/*.md` ✅ (7 files: 6 core + review)

---

### PR #2: Core Architecture & Constants
**Branch:** `feature/core-architecture`  
**Description:** Set up MVVM architecture, base services, constants  
**Timeline:** Day 1-2

**Tasks:**
- [ ] Create base constants
  - File: `Utilities/Constants/FirebaseConstants.swift`
  - File: `Utilities/Constants/AppConstants.swift`
- [ ] Create Firebase configuration
  - File: `Configuration/FirebaseConfig.swift`
- [ ] Create utility extensions
  - File: `Utilities/Extensions/Date+Extensions.swift`
  - File: `Utilities/Extensions/String+Extensions.swift`
  - File: `Utilities/Extensions/View+Extensions.swift`
- [ ] Create helper utilities
  - File: `Utilities/Helpers/UserDefaultsManager.swift`
  - File: `Utilities/Helpers/KeychainManager.swift`
  - File: `Utilities/Helpers/DateFormatter+Shared.swift`
- [ ] Create base error handling
  - File: `Utilities/AppError.swift`
- [ ] Set up SwiftLint configuration
  - File: `.swiftlint.yml`
- [ ] Create reusable components
  - File: `Views/Components/LoadingView.swift`
  - File: `Views/Components/ErrorView.swift`
  - File: `Views/Components/EmptyStateView.swift`
- [ ] **Write unit tests for utilities**
  - File: `MessengerAITests/Utilities/DateExtensionsTests.swift`
  - File: `MessengerAITests/Utilities/StringExtensionsTests.swift`
  - File: `MessengerAITests/Utilities/UserDefaultsManagerTests.swift`
  - File: `MessengerAITests/Utilities/KeychainManagerTests.swift`

**Test Coverage:**
- ✅ Date formatting functions
- ✅ String validation (email, non-empty)
- ✅ UserDefaults save/retrieve operations
- ✅ Keychain secure storage operations

**Files Created:**
- `Utilities/Constants/FirebaseConstants.swift`
- `Utilities/Constants/AppConstants.swift`
- `Configuration/FirebaseConfig.swift`
- `Utilities/Extensions/Date+Extensions.swift`
- `Utilities/Extensions/String+Extensions.swift`
- `Utilities/Extensions/View+Extensions.swift`
- `Utilities/Helpers/UserDefaultsManager.swift`
- `Utilities/Helpers/KeychainManager.swift`
- `Utilities/Helpers/DateFormatter+Shared.swift`
- `Utilities/AppError.swift`
- `Views/Components/LoadingView.swift`
- `Views/Components/ErrorView.swift`
- `Views/Components/EmptyStateView.swift`
- `.swiftlint.yml`
- `MessengerAITests/Utilities/DateExtensionsTests.swift`
- `MessengerAITests/Utilities/StringExtensionsTests.swift`
- `MessengerAITests/Utilities/UserDefaultsManagerTests.swift`
- `MessengerAITests/Utilities/KeychainManagerTests.swift`

---

### PR #3: Data Models
**Branch:** `feature/data-models`  
**Description:** Create all data models for the app  
**Timeline:** Day 2

**Tasks:**
- [ ] Create User model
  - File: `Models/User.swift`
  - Properties: id, displayName, email, avatarURL, isOnline, lastSeen, fcmToken, createdAt
  - Conform to: Codable, Identifiable
- [ ] Create Conversation model
  - File: `Models/Conversation.swift`
  - Properties: id, participants, lastMessage, lastMessageTimestamp, unreadCount, createdAt
- [ ] Create MessageStatus enum
  - File: `Models/MessageStatus.swift`
  - Cases: sending, sent, delivered, read, failed
- [ ] Create Message model
  - File: `Models/Message.swift`
  - Properties: id, conversationID, senderID, content, timestamp, deliveredAt, readAt, status
- [ ] Create ActionItem model
  - File: `Models/ActionItem.swift`
  - Properties: id, conversationID, messageID, description, assignedTo, dueDate, isCompleted, createdAt
- [ ] Create ConversationSummary model
  - File: `Models/ConversationSummary.swift`
  - Properties: conversationID, messageRange, keyPoints, decisions, actionItems, openQuestions, createdAt
- [ ] Create AISuggestion model
  - File: `Models/AISuggestion.swift`
  - Properties: clarityIssues, suggestedRevision, toneWarning, alternativePhrasing
- [ ] **Write comprehensive unit tests for all models**
  - File: `MessengerAITests/Models/UserModelTests.swift`
  - File: `MessengerAITests/Models/ConversationModelTests.swift`
  - File: `MessengerAITests/Models/MessageModelTests.swift`
  - File: `MessengerAITests/Models/ActionItemModelTests.swift`
  - File: `MessengerAITests/Models/ConversationSummaryModelTests.swift`
  - File: `MessengerAITests/Models/AISuggestionModelTests.swift`

**Test Coverage (Critical for Verification):**
- ✅ **Encoding/Decoding**: Verify each model can be encoded to JSON and decoded back
- ✅ **Required Properties**: Test that required fields are present
- ✅ **Optional Properties**: Test handling of nil values
- ✅ **Date Handling**: Verify timestamp serialization
- ✅ **Enum Raw Values**: Test MessageStatus enum cases
- ✅ **Nested Objects**: Test Message with nested AISuggestion
- ✅ **Array Properties**: Test Conversation with participants array
- ✅ **Dictionary Properties**: Test unreadCount dictionary in Conversation
- ✅ **Default Values**: Test any computed or default properties
- ✅ **Identifiable Conformance**: Verify id property works correctly

**Example Test Cases:**
```swift
// UserModelTests.swift
func testUserEncoding() { /* encode User to JSON */ }
func testUserDecoding() { /* decode User from JSON */ }
func testUserWithOptionalFields() { /* test with nil avatarURL */ }

// MessageModelTests.swift
func testMessageWithAllStatuses() { /* test each status */ }
func testMessageTimestampHandling() { /* verify Date serialization */ }
func testMessageWithAISuggestions() { /* test nested object */ }
```

**Files Created:**
- `Models/User.swift`
- `Models/Conversation.swift`
- `Models/MessageStatus.swift`
- `Models/Message.swift`
- `Models/ActionItem.swift`
- `Models/ConversationSummary.swift`
- `Models/AISuggestion.swift`
- `MessengerAITests/Models/UserModelTests.swift`
- `MessengerAITests/Models/ConversationModelTests.swift`
- `MessengerAITests/Models/MessageModelTests.swift`
- `MessengerAITests/Models/ActionItemModelTests.swift`
- `MessengerAITests/Models/ConversationSummaryModelTests.swift`
- `MessengerAITests/Models/AISuggestionModelTests.swift`

---

### PR #4: Authentication Service & Repository
**Branch:** `feature/authentication`  
**Description:** Implement Firebase Authentication  
**Timeline:** Day 2

**Tasks:**
- [ ] Create AuthenticationService
  - File: `Services/AuthenticationService.swift`
  - Methods: signUp, signIn, signOut, getCurrentUser, updateProfile
  - Use Firebase Auth SDK
- [ ] Create UserRepository
  - File: `Repositories/UserRepository.swift`
  - Methods: createUser, getUser, updateUser, observeUser, setOnlineStatus
  - Use Firestore SDK
- [ ] Create AuthViewModel
  - File: `ViewModels/AuthViewModel.swift`
  - Properties: currentUser, isAuthenticated, errorMessage
  - Methods: signUp, signIn, signOut
  - Use @Published properties for reactive updates
- [ ] **Write comprehensive unit tests**
  - File: `MessengerAITests/Services/AuthenticationServiceTests.swift`
  - File: `MessengerAITests/Repositories/UserRepositoryTests.swift`
  - File: `MessengerAITests/ViewModels/AuthViewModelTests.swift`

**Test Coverage (Critical for Verification):**

**AuthenticationService Tests:**
- ✅ `testSignUpWithValidCredentials()` - Verify successful signup
- ✅ `testSignUpWithInvalidEmail()` - Verify email validation
- ✅ `testSignUpWithWeakPassword()` - Verify password requirements
- ✅ `testSignUpWithExistingEmail()` - Verify duplicate email handling
- ✅ `testSignInWithValidCredentials()` - Verify successful login
- ✅ `testSignInWithInvalidCredentials()` - Verify error handling
- ✅ `testSignInWithNonExistentUser()` - Verify user not found error
- ✅ `testSignOut()` - Verify logout clears session
- ✅ `testGetCurrentUserWhenAuthenticated()` - Verify user retrieval
- ✅ `testGetCurrentUserWhenNotAuthenticated()` - Verify nil return

**UserRepository Tests:**
- ✅ `testCreateUserInFirestore()` - Verify user document creation
- ✅ `testGetUserById()` - Verify user retrieval by ID
- ✅ `testGetNonExistentUser()` - Verify error handling
- ✅ `testUpdateUserProfile()` - Verify profile update
- ✅ `testSetOnlineStatus()` - Verify online/offline status
- ✅ `testObserveUserChanges()` - Verify real-time listener
- ✅ `testUpdateLastSeen()` - Verify timestamp updates

**AuthViewModel Tests:**
- ✅ `testSignUpSuccess()` - Verify state changes on success
- ✅ `testSignUpFailure()` - Verify error message appears
- ✅ `testSignInSuccess()` - Verify authentication state
- ✅ `testSignInFailure()` - Verify error handling
- ✅ `testSignOut()` - Verify state reset
- ✅ `testIsAuthenticatedProperty()` - Verify computed property
- ✅ `testErrorMessageClearing()` - Verify error state management

**Mock Requirements:**
- Use Firebase Auth Emulator for testing
- Mock UserRepository for ViewModel tests
- Test async/await operations correctly

**Files Created:**
- `Services/AuthenticationService.swift`
- `Repositories/UserRepository.swift`
- `ViewModels/AuthViewModel.swift`
- `MessengerAITests/Services/AuthenticationServiceTests.swift`
- `MessengerAITests/Repositories/UserRepositoryTests.swift`
- `MessengerAITests/ViewModels/AuthViewModelTests.swift`

---

### PR #5: Authentication UI
**Branch:** `feature/auth-ui`  
**Description:** Build login and signup screens  
**Timeline:** Day 2

**Tasks:**
- [ ] Create LoginView
  - File: `Views/Authentication/LoginView.swift`
  - Fields: email, password
  - Button: Login
  - Link: "Don't have an account? Sign Up"
- [ ] Create SignUpView
  - File: `Views/Authentication/SignUpView.swift`
  - Fields: displayName, email, password, confirmPassword
  - Button: Sign Up
  - Link: "Already have an account? Login"
- [ ] Create AuthContainerView
  - File: `Views/Authentication/AuthContainerView.swift`
  - Manages navigation between Login and SignUp
- [ ] Update MessengerAIApp.swift to show AuthContainerView when not authenticated
  - Update: `App/MessengerAIApp.swift`
- [ ] Add input validation and error display
- [ ] Write UI tests for authentication flow
  - File: `MessengerAIUITests/AuthenticationUITests.swift`

**Files Created:**
- `Views/Authentication/LoginView.swift`
- `Views/Authentication/SignUpView.swift`
- `Views/Authentication/AuthContainerView.swift`
- `MessengerAIUITests/AuthenticationUITests.swift`

**Files Updated:**
- `App/MessengerAIApp.swift`

---

## 🎯 Phase 1: Core Messaging Infrastructure

### PR #6: Conversation Infrastructure
**Branch:** `feature/conversations`  
**Description:** Implement conversation creation and repository  
**Timeline:** Day 3

**Tasks:**
- [ ] Create ConversationRepository
  - File: `Repositories/ConversationRepository.swift`
  - Methods: createConversation, getConversations, observeConversations, updateLastMessage, updateUnreadCount
  - Use Firestore listeners for real-time updates
- [ ] Create ConversationListViewModel
  - File: `ViewModels/ConversationListViewModel.swift`
  - Properties: conversations, isLoading, errorMessage
  - Methods: loadConversations, createNewConversation
  - Use @Published properties
- [ ] Set up Firestore security rules (initial version)
  - File: `CloudFunctions/firestore.rules`
  - Rules: User can only read/write their own conversations
- [ ] **Write comprehensive unit tests**
  - File: `MessengerAITests/Repositories/ConversationRepositoryTests.swift`
  - File: `MessengerAITests/ViewModels/ConversationListViewModelTests.swift`

**Test Coverage (Critical for Verification):**

**ConversationRepository Tests:**
- ✅ `testCreateConversation()` - Verify conversation creation with 2 participants
- ✅ `testCreateDuplicateConversation()` - Verify duplicate prevention
- ✅ `testGetConversationsForUser()` - Verify user can see their conversations
- ✅ `testGetConversationsReturnsEmpty()` - Verify empty state
- ✅ `testObserveConversationsRealTime()` - Verify listener updates
- ✅ `testUpdateLastMessage()` - Verify last message update
- ✅ `testUpdateUnreadCount()` - Verify unread increment/decrement
- ✅ `testResetUnreadCount()` - Verify count resets to 0
- ✅ `testConversationSortedByTimestamp()` - Verify most recent first
- ✅ `testGetConversationById()` - Verify specific conversation retrieval

**ConversationListViewModel Tests:**
- ✅ `testLoadConversationsSuccess()` - Verify conversations load
- ✅ `testLoadConversationsFailure()` - Verify error handling
- ✅ `testCreateNewConversation()` - Verify conversation creation
- ✅ `testLoadingStateChanges()` - Verify isLoading toggles
- ✅ `testConversationsUpdateRealTime()` - Verify listener integration
- ✅ `testErrorMessageAppears()` - Verify error state
- ✅ `testConversationsSortOrder()` - Verify UI sorting

**Mock Requirements:**
- Use Firestore Emulator for repository tests
- Mock ConversationRepository for ViewModel tests
- Test async/await operations
- Test Combine publishers

**Files Created:**
- `Repositories/ConversationRepository.swift`
- `ViewModels/ConversationListViewModel.swift`
- `CloudFunctions/firestore.rules`
- `MessengerAITests/Repositories/ConversationRepositoryTests.swift`
- `MessengerAITests/ViewModels/ConversationListViewModelTests.swift`

---

### PR #7: Conversation List UI
**Branch:** `feature/conversation-list-ui`  
**Description:** Build conversation list view  
**Timeline:** Day 3

**Tasks:**
- [ ] Create ConversationListView
  - File: `Views/Conversations/ConversationListView.swift`
  - Display list of conversations
  - Show unread badge
  - Pull to refresh
  - Navigation to ChatView
- [ ] Create ConversationRowView
  - File: `Views/Conversations/ConversationRowView.swift`
  - Show: avatar, name, last message preview, timestamp, unread count
  - Show online/offline indicator
- [ ] Create NewConversationView
  - File: `Views/Conversations/NewConversationView.swift`
  - Search/select user to start conversation
  - Button to create new conversation
- [ ] Update MessengerAIApp.swift to show ConversationListView after auth
  - Update: `App/MessengerAIApp.swift`
- [ ] Add navigation bar with logout button
- [ ] Write UI tests
  - File: `MessengerAIUITests/ConversationListUITests.swift`

**Files Created:**
- `Views/Conversations/ConversationListView.swift`
- `Views/Conversations/ConversationRowView.swift`
- `Views/Conversations/NewConversationView.swift`
- `MessengerAIUITests/ConversationListUITests.swift`

**Files Updated:**
- `App/MessengerAIApp.swift`

---

### PR #8: Message Repository & Basic Messaging
**Branch:** `feature/message-repository`  
**Description:** Implement message sending and receiving  
**Timeline:** Day 4

**Tasks:**
- [ ] Create MessageRepository
  - File: `Repositories/MessageRepository.swift`
  - Methods: sendMessage, observeMessages, updateMessageStatus, markAsRead, getMessagesPaginated
  - Use Firestore batch writes for atomic operations
  - Implement pagination (50 messages per load)
- [ ] Create ChatViewModel
  - File: `ViewModels/ChatViewModel.swift`
  - Properties: messages, isLoading, conversation, typingUsers
  - Methods: sendMessage, loadMoreMessages, markAsRead, startTyping, stopTyping
  - Use @Published properties
  - Implement real-time listeners
- [ ] **Write comprehensive unit and integration tests**
  - File: `MessengerAITests/Repositories/MessageRepositoryTests.swift`
  - File: `MessengerAITests/ViewModels/ChatViewModelTests.swift`
  - File: `MessengerAITests/Integration/MessagingFlowTests.swift`

**Test Coverage (Critical for Verification):**

**MessageRepository Tests:**
- ✅ `testSendMessage()` - Verify message sent to Firestore
- ✅ `testSendMessageCreatesWithCorrectFields()` - Verify all fields populated
- ✅ `testSendMessageUpdatesConversation()` - Verify lastMessage updated
- ✅ `testObserveMessagesRealTime()` - Verify listener receives new messages
- ✅ `testObserveMessagesInOrder()` - Verify chronological order
- ✅ `testUpdateMessageStatus()` - Verify status changes (sent → delivered → read)
- ✅ `testMarkAsRead()` - Verify read status and timestamp
- ✅ `testMarkMultipleAsRead()` - Verify batch read operations
- ✅ `testGetMessagesPaginated()` - Verify pagination returns 50 messages
- ✅ `testLoadMoreMessages()` - Verify next page loads correctly
- ✅ `testPaginationEndsCorrectly()` - Verify no more pages when exhausted
- ✅ `testSendVeryLongMessage()` - Verify 9000+ character messages
- ✅ `testSendEmptyMessage()` - Verify validation prevents empty sends
- ✅ `testConcurrentMessageSends()` - Verify no conflicts

**ChatViewModel Tests:**
- ✅ `testSendMessageSuccess()` - Verify message appears in messages array
- ✅ `testSendMessageUpdatesUI()` - Verify @Published properties trigger
- ✅ `testSendMessageFailure()` - Verify error handling
- ✅ `testLoadMoreMessagesSuccess()` - Verify pagination works in VM
- ✅ `testLoadMoreMessagesAtEnd()` - Verify stops loading at end
- ✅ `testMarkAsReadWhenVisible()` - Verify automatic read marking
- ✅ `testStartTyping()` - Verify typing indicator logic
- ✅ `testStopTyping()` - Verify typing stops after delay
- ✅ `testTypingDebounce()` - Verify debounce logic (2 seconds)
- ✅ `testMessagesUpdateRealTime()` - Verify listener integration
- ✅ `testLoadingStateChanges()` - Verify isLoading toggles
- ✅ `testNewMessageScrollsToBottom()` - Verify UI behavior

**Integration Tests:**
- ✅ `testEndToEndMessageFlow()` - Send, receive, mark as read
- ✅ `testTwoUserConversation()` - Simulate 2 users messaging
- ✅ `testMessageStatusProgression()` - Verify sending → sent → delivered → read
- ✅ `testTypingIndicatorBetweenUsers()` - Verify both users see typing
- ✅ `testRapidMessaging()` - Send 10 messages quickly, verify order
- ✅ `testLongConversationPagination()` - Test with 150+ messages

**Mock Requirements:**
- Use Firestore Emulator for repository tests
- Mock MessageRepository for ViewModel tests
- Mock real-time listeners for predictable testing
- Test async/await and Combine publishers

**Performance Requirements:**
- Message send should complete in < 500ms
- Pagination should load in < 1 second
- Real-time updates should appear in < 500ms

**Files Created:**
- `Repositories/MessageRepository.swift`
- `ViewModels/ChatViewModel.swift`
- `MessengerAITests/Repositories/MessageRepositoryTests.swift`
- `MessengerAITests/ViewModels/ChatViewModelTests.swift`
- `MessengerAITests/Integration/MessagingFlowTests.swift`

---

### PR #9: Chat UI - Message Display
**Branch:** `feature/chat-ui-messages`  
**Description:** Build chat view with message bubbles  
**Timeline:** Day 4

**Tasks:**
- [ ] Create ChatView
  - File: `Views/Chat/ChatView.swift`
  - ScrollView with messages
  - Infinite scroll (pagination)
  - Auto-scroll to bottom on new message
  - Date separators
- [ ] Create MessageBubbleView
  - File: `Views/Chat/MessageBubbleView.swift`
  - Different styling for sent vs received
  - Show timestamp
  - Show message status (for sent messages)
  - Handle long messages (word wrap)
- [ ] Create MessageStatusView
  - File: `Views/Chat/MessageStatusView.swift`
  - Icons for: sending, sent, delivered, read, failed
- [ ] Create TypingIndicatorView
  - File: `Views/Chat/TypingIndicatorView.swift`
  - Animated dots when other user is typing
- [ ] Add navigation bar with user info and online status
- [ ] Write UI tests
  - File: `MessengerAIUITests/ChatUITests.swift`

**Files Created:**
- `Views/Chat/ChatView.swift`
- `Views/Chat/MessageBubbleView.swift`
- `Views/Chat/MessageStatusView.swift`
- `Views/Chat/TypingIndicatorView.swift`
- `MessengerAIUITests/ChatUITests.swift`

---

### PR #10: Chat UI - Message Input
**Branch:** `feature/chat-ui-input`  
**Description:** Build message input with send functionality  
**Timeline:** Day 5

**Tasks:**
- [ ] Create MessageInputView
  - File: `Views/Chat/MessageInputView.swift`
  - Text field with dynamic height (up to 5 lines)
  - Send button
  - Character count indicator (when approaching limit)
- [ ] Create MessageInputViewModel
  - File: `ViewModels/MessageInputViewModel.swift`
  - Properties: messageText, isSending
  - Methods: sendMessage, updateTypingStatus
  - Debounced typing indicator logic
- [ ] Integrate MessageInputView into ChatView
  - Update: `Views/Chat/ChatView.swift`
- [ ] Add keyboard management (dismiss on scroll, safe area)
- [ ] Implement typing indicator logic
- [ ] Write UI tests
  - File: `MessengerAIUITests/MessageInputUITests.swift`

**Files Created:**
- `Views/Chat/MessageInputView.swift`
- `ViewModels/MessageInputViewModel.swift`
- `MessengerAIUITests/MessageInputUITests.swift`

**Files Updated:**
- `Views/Chat/ChatView.swift`

---

### PR #11: Message Status & Read Receipts
**Branch:** `feature/message-status`  
**Description:** Implement message delivery and read receipts  
**Timeline:** Day 5

**Tasks:**
- [ ] Add message status update logic in MessageRepository
  - Update: `Repositories/MessageRepository.swift`
  - Update status: sending → sent → delivered → read
  - Use Firestore onSnapshot for real-time updates
- [ ] Implement read receipt logic
  - Update: `ViewModels/ChatViewModel.swift`
  - Mark messages as read when view appears and user scrolls to them
- [ ] Update MessageBubbleView to show correct status
  - Update: `Views/Chat/MessageBubbleView.swift`
- [ ] Add "message delivered" and "message read" indicators
  - Update: `Views/Chat/MessageStatusView.swift`
- [ ] Handle offline scenarios (show "sending" until online)
- [ ] **Write integration tests for status flow**
  - File: `MessengerAITests/Integration/MessageStatusIntegrationTests.swift`

**Test Coverage (Critical for Verification):**

**Message Status Integration Tests:**
- ✅ `testMessageStatusProgression()` - Verify sending → sent → delivered → read
- ✅ `testSenderSeesDeliveredStatus()` - When recipient receives message
- ✅ `testSenderSeesReadStatus()` - When recipient opens conversation
- ✅ `testRecipientOfflineStatus()` - Message stays at "sent" until recipient online
- ✅ `testRecipientComesOnline()` - Status updates to "delivered" automatically
- ✅ `testMultipleMessagesReadAtOnce()` - Batch read receipt handling
- ✅ `testReadReceiptRealTimeUpdate()` - Sender sees read status immediately
- ✅ `testTypingDoesNotTriggerRead()` - Only scrolling to message triggers read
- ✅ `testReadStatusPersists()` - Read status saved in Firestore
- ✅ `testUnreadMessagesCount()` - Count decrements when marked as read
- ✅ `testStatusIconsDisplay()` - Verify correct icon for each status
- ✅ `testFailedMessageRetry()` - Verify retry updates status correctly

**Scenario Tests:**
- ✅ `testScenario_BothUsersOnline()` - Complete flow both online
- ✅ `testScenario_RecipientOffline()` - Send when recipient offline
- ✅ `testScenario_RecipientComesBack()` - Recipient returns and opens app
- ✅ `testScenario_AppBackgrounded()` - Status updates when app in background
- ✅ `testScenario_RapidStatusChanges()` - Multiple status changes in sequence

**Mock Requirements:**
- Mock NetworkMonitor for online/offline simulation
- Use Firestore Emulator for real-time status updates
- Simulate user actions (opening conversation, scrolling)

**Performance Requirements:**
- Status updates should propagate in < 500ms
- Read receipts should appear in < 1 second

**Files Updated:**
- `Repositories/MessageRepository.swift`
- `ViewModels/ChatViewModel.swift`
- `Views/Chat/MessageBubbleView.swift`
- `Views/Chat/MessageStatusView.swift`

**Files Created:**
- `MessengerAITests/Integration/MessageStatusIntegrationTests.swift`

---

### PR #12: Offline Support Infrastructure
**Branch:** `feature/offline-support`  
**Description:** Implement offline detection and message queue  
**Timeline:** Day 6

**Tasks:**
- [ ] Create NetworkMonitor service
  - File: `Services/NetworkMonitor.swift`
  - Monitor network connectivity using NWPathMonitor
  - Publish connectivity status
- [ ] Create OfflineQueueService
  - File: `Services/OfflineQueueService.swift`
  - Methods: enqueue, dequeueAll, isEmpty
  - Persist queued messages to UserDefaults
  - Auto-send when connectivity restored
- [ ] Enable Firestore offline persistence
  - Update: `Configuration/FirebaseConfig.swift`
  - Enable: `Firestore.firestore().settings.isPersistenceEnabled = true`
- [ ] Add offline state indicators to UI
  - Update: `Views/Conversations/ConversationListView.swift`
  - Update: `Views/Chat/ChatView.swift`
  - Show banner when offline
- [ ] Integrate OfflineQueueService into MessageRepository
  - Update: `Repositories/MessageRepository.swift`
- [ ] **Write comprehensive unit tests**
  - File: `MessengerAITests/Services/NetworkMonitorTests.swift`
  - File: `MessengerAITests/Services/OfflineQueueServiceTests.swift`
  - File: `MessengerAITests/Integration/OfflineSupportTests.swift`

**Test Coverage (Critical for Verification):**

**NetworkMonitor Tests:**
- ✅ `testNetworkMonitorInitialization()` - Verify monitor starts correctly
- ✅ `testDetectOnlineState()` - Verify online detection
- ✅ `testDetectOfflineState()` - Verify offline detection
- ✅ `testNetworkTransitionOnlineToOffline()` - Verify state change
- ✅ `testNetworkTransitionOfflineToOnline()` - Verify reconnection
- ✅ `testPublishesStatusUpdates()` - Verify Combine publisher works
- ✅ `testMultipleSubscribers()` - Verify multiple listeners work
- ✅ `testStatusPersistsAcrossAppStates()` - Verify background handling

**OfflineQueueService Tests:**
- ✅ `testEnqueueMessage()` - Verify message added to queue
- ✅ `testEnqueueMultipleMessages()` - Verify FIFO order maintained
- ✅ `testDequeueAll()` - Verify all messages retrieved
- ✅ `testDequeueAllClearsQueue()` - Verify queue empty after dequeue
- ✅ `testIsEmptyTrue()` - Verify isEmpty when no messages
- ✅ `testIsEmptyFalse()` - Verify isEmpty when messages queued
- ✅ `testPersistenceAcrossAppRestart()` - Verify UserDefaults persistence
- ✅ `testQueueLimit()` - Verify max queue size (prevent memory issues)
- ✅ `testMessageOrderPreserved()` - Verify chronological order
- ✅ `testClearQueue()` - Verify manual clearing
- ✅ `testQueueWithDuplicateMessages()` - Verify duplicate handling

**Integration Tests:**
- ✅ `testOfflineMessageQueuing()` - Send message while offline, verify queued
- ✅ `testAutoSendOnReconnect()` - Verify auto-send when online
- ✅ `testQueuePersistsThroughAppRestart()` - Close and reopen app
- ✅ `testMultipleOfflineMessages()` - Queue 5 messages, verify all send
- ✅ `testOfflineQueueUIIndicator()` - Verify "queued" badge shows
- ✅ `testFirestoreOfflineCache()` - Verify cached data accessible offline
- ✅ `testReadMessagesWhileOffline()` - Verify message history loads

**Edge Cases:**
- ✅ `testGoOfflineWhileSending()` - Network drops mid-send
- ✅ `testRapidOnlineOfflineTransitions()` - Flaky network simulation
- ✅ `testVeryLargeQueue()` - 50+ messages in queue
- ✅ `testQueueCorruption()` - Handle corrupted UserDefaults data

**Mock Requirements:**
- Mock NWPathMonitor for controlled network states
- Mock UserDefaults for queue persistence testing
- Mock Firestore for offline cache testing

**Files Created:**
- `Services/NetworkMonitor.swift`
- `Services/OfflineQueueService.swift`
- `MessengerAITests/Services/NetworkMonitorTests.swift`
- `MessengerAITests/Services/OfflineQueueServiceTests.swift`
- `MessengerAITests/Integration/OfflineSupportTests.swift`

**Files Updated:**
- `Configuration/FirebaseConfig.swift`
- `Repositories/MessageRepository.swift`
- `Views/Conversations/ConversationListView.swift`
- `Views/Chat/ChatView.swift`

---

### PR #13: Offline Message Sync
**Branch:** `feature/offline-sync`  
**Description:** Handle offline message composition and sync  
**Timeline:** Day 7

**Tasks:**
- [ ] Implement offline message composition
  - Update: `ViewModels/MessageInputViewModel.swift`
  - Queue messages when offline
  - Show "queued" status
- [ ] Add automatic sync when connection restored
  - Update: `Services/OfflineQueueService.swift`
  - Listen to NetworkMonitor changes
  - Auto-send queued messages
- [ ] Handle send failures gracefully
  - Update: `Repositories/MessageRepository.swift`
  - Retry logic with exponential backoff
  - Show error state in UI
- [ ] Implement conflict resolution
  - Handle scenarios where message order matters
- [ ] Add visual feedback for sync status
  - Update: `Views/Chat/MessageBubbleView.swift`
  - Show: queued, syncing, failed
- [ ] **Write comprehensive integration tests**
  - File: `MessengerAITests/Integration/OfflineSyncIntegrationTests.swift`

**Test Coverage (Critical for Verification):**

**Offline Sync Integration Tests:**
- ✅ `testSendMessageWhileOffline()` - Message queued, not sent
- ✅ `testAutoSyncWhenOnline()` - Queue syncs automatically on reconnect
- ✅ `testMultipleOfflineMessages()` - 5+ messages queue and sync in order
- ✅ `testOfflineMessageOrder()` - Verify chronological order maintained
- ✅ `testQueuedMessageVisibility()` - User sees "queued" badge
- ✅ `testSyncProgressIndicator()` - Shows "syncing" during upload
- ✅ `testSyncCompletionUpdate()` - Status changes to "sent" after sync
- ✅ `testFailedSyncRetry()` - Automatic retry on failure
- ✅ `testExponentialBackoff()` - Verify retry delays: 1s, 2s, 4s, 8s
- ✅ `testMaxRetryAttempts()` - Stop after 5 failed attempts
- ✅ `testPermanentFailureHandling()` - Show error UI after max retries
- ✅ `testManualRetry()` - User can tap to retry failed message
- ✅ `testClearFailedMessages()` - User can delete failed messages

**Conflict Resolution Tests:**
- ✅ `testTwoUsersSendSimultaneously()` - No message loss
- ✅ `testOfflineEditNoConflict()` - Messages are immutable (no conflicts)
- ✅ `testTimestampOrdering()` - Server timestamp determines order
- ✅ `testDuplicatePrevention()` - Same message doesn't send twice

**Network Interruption Tests:**
- ✅ `testNetworkDropsDuringSync()` - Handles mid-send interruption
- ✅ `testFlakeyConnection()` - Multiple on/off transitions
- ✅ `testPartialSyncCompletion()` - 3 of 5 messages send, resume others
- ✅ `testLongOfflinePeriod()` - Queue persists for hours

**App Lifecycle Tests:**
- ✅ `testAppBackgroundedWhileQueued()` - Queue persists
- ✅ `testAppRelaunchedWithQueue()` - Queue loads and syncs
- ✅ `testAppTerminatedWithQueue()` - Queue persists to disk
- ✅ `testSyncContinuesInBackground()` - Background task completes sync

**UI State Tests:**
- ✅ `testQueuedBadgeDisplay()` - "Queued (3)" shows
- ✅ `testSyncingSpinnerDisplay()` - Loading indicator during sync
- ✅ `testFailedMessageRedIcon()` - Error icon for failed messages
- ✅ `testRetryButtonAppears()` - Retry option for failed messages

**Performance Tests:**
- ✅ `testLargeQueuePerformance()` - 50+ messages sync efficiently
- ✅ `testSyncDoesNotBlockUI()` - UI remains responsive during sync
- ✅ `testBatchSyncOptimization()` - Messages sent in batches, not individually

**Mock Requirements:**
- Mock NetworkMonitor for on/off transitions
- Mock Firestore for send failures
- Mock system clock for retry timing tests
- Simulate background app state

**Success Criteria:**
- 100% of queued messages eventually sync (no loss)
- Sync completes within 10 seconds of reconnection
- UI always shows accurate sync state
- No crashes during sync process

**Files Updated:**
- `ViewModels/MessageInputViewModel.swift`
- `Services/OfflineQueueService.swift`
- `Repositories/MessageRepository.swift`
- `Views/Chat/MessageBubbleView.swift`

**Files Created:**
- `MessengerAITests/Integration/OfflineSyncIntegrationTests.swift`

---

### PR #14: Message History & Search
**Branch:** `feature/message-history-search`  
**Description:** Add pagination and search functionality  
**Timeline:** Day 8

**Tasks:**
- [ ] Implement infinite scroll with pagination
  - Update: `ViewModels/ChatViewModel.swift`
  - Load 50 messages at a time
  - Load more when user scrolls to top
- [ ] Add date separators in chat
  - Update: `Views/Chat/ChatView.swift`
  - Group messages by date
  - Show date header
- [ ] Implement search functionality
  - Update: `Repositories/MessageRepository.swift`
  - Add searchMessages method
  - Full-text search in Firestore
- [ ] Create search UI
  - File: `Views/Chat/MessageSearchView.swift`
  - Search bar in navigation
  - Display search results
  - Navigate to message in conversation
- [ ] Optimize Firestore queries
  - Add composite indexes in Firebase Console
- [ ] **Write unit and performance tests**
  - File: `MessengerAITests/Repositories/MessageSearchTests.swift`
  - File: `MessengerAITests/ViewModels/ChatPaginationTests.swift`
  - File: `MessengerAITests/Performance/MessageLoadingPerformanceTests.swift`

**Test Coverage (Critical for Verification):**

**Pagination Tests:**
- ✅ `testInitialLoad()` - Load first 50 messages
- ✅ `testInitialLoadLessThan50()` - Handle conversations with < 50 messages
- ✅ `testLoadMoreMessages()` - Load next 50 messages
- ✅ `testLoadMoreAtEnd()` - No more messages available
- ✅ `testPaginationMaintainsOrder()` - Messages stay chronological
- ✅ `testNoDuplicatesInPagination()` - Same message not loaded twice
- ✅ `testScrollToTopTriggersLoad()` - Auto-load when near top
- ✅ `testLoadingIndicatorAtTop()` - Shows loading when paginating
- ✅ `testMultiplePaginationCalls()` - Load 3+ pages sequentially
- ✅ `testPaginationWithRealTimeMessages()` - New messages while paginating

**Search Tests:**
- ✅ `testSearchByKeyword()` - Find messages containing "bug"
- ✅ `testSearchCaseInsensitive()` - "Bug" finds "bug"
- ✅ `testSearchMultipleResults()` - Returns all matching messages
- ✅ `testSearchNoResults()` - Handle empty search results
- ✅ `testSearchByPhrase()` - Find "feature request"
- ✅ `testSearchWithSpecialCharacters()` - Handle @#$%
- ✅ `testSearchInDateRange()` - Filter by date range
- ✅ `testSearchBySender()` - Find all messages from specific user
- ✅ `testSearchResultsHighlight()` - Highlight search term in results
- ✅ `testNavigateToSearchResult()` - Jump to message in chat
- ✅ `testSearchPagination()` - Paginate search results if many

**Date Separator Tests:**
- ✅ `testDateSeparatorsDisplay()` - "Today", "Yesterday", dates
- ✅ `testDateGrouping()` - Messages grouped by date correctly
- ✅ `testDateSeparatorOnScroll()` - Separators maintain position
- ✅ `testDateSeparatorWithPagination()` - Separators update as loading

**Performance Tests:**
- ✅ `testInitialLoadSpeed()` - < 1 second for 50 messages
- ✅ `testPaginationSpeed()` - < 1 second per page
- ✅ `testSearchSpeed()` - < 500ms for search
- ✅ `testLargeConversationLoad()` - 500+ messages handle well
- ✅ `testMemoryUsagePagination()` - Memory doesn't grow unbounded
- ✅ `testScrollPerformance()` - 60fps while scrolling
- ✅ `testRenderingPerformance()` - Message bubbles render quickly
- ✅ `testConcurrentOperations()` - Search + pagination simultaneously

**Edge Cases:**
- ✅ `testEmptyConversation()` - Handle 0 messages
- ✅ `testSingleMessage()` - Handle 1 message
- ✅ `testExactly50Messages()` - Boundary case
- ✅ `testVeryLongMessages()` - 9000+ character messages
- ✅ `testMessagesWithEmoji()` - Handle emoji rendering
- ✅ `testMessagesWithURLs()` - Handle URL detection

**Mock Requirements:**
- Mock MessageRepository with large datasets
- Mock Firestore queries for controlled pagination
- Use XCTest performance testing APIs
- Test with realistic message content

**Performance Requirements:**
- Initial load: < 1 second
- Pagination: < 1 second per page
- Search: < 500ms
- Scroll performance: 60fps
- Memory: < 100MB for 500 messages

**Files Updated:**
- `ViewModels/ChatViewModel.swift`
- `Views/Chat/ChatView.swift`
- `Repositories/MessageRepository.swift`

**Files Created:**
- `Views/Chat/MessageSearchView.swift`
- `MessengerAITests/Repositories/MessageSearchTests.swift`
- `MessengerAITests/ViewModels/ChatPaginationTests.swift`
- `MessengerAITests/Performance/MessageLoadingPerformanceTests.swift`

---

### PR #15: Edge Cases & Error Handling
**Branch:** `feature/edge-cases`  
**Description:** Handle edge cases and improve error handling  
**Timeline:** Day 9

**Tasks:**
- [ ] Implement app backgrounding/foregrounding logic
  - Update: `App/AppDelegate.swift`
  - Pause/resume Firestore listeners
  - Update user online status
- [ ] Handle network interruptions gracefully
  - Update: `Services/NetworkMonitor.swift`
  - Show reconnecting state
  - Auto-retry failed operations
- [ ] Handle very long messages (9000+ characters)
  - Update: `Views/Chat/MessageBubbleView.swift`
  - Proper text wrapping
  - "Show more/less" for extremely long messages
- [ ] Handle rapid message sending
  - Update: `ViewModels/MessageInputViewModel.swift`
  - Prevent duplicate sends
  - Rate limiting
- [ ] Improve error UI/UX
  - Update: `Views/Components/ErrorView.swift`
  - User-friendly error messages
  - Retry buttons
- [ ] **Write comprehensive edge case tests**
  - File: `MessengerAITests/EdgeCases/AppLifecycleTests.swift`
  - File: `MessengerAITests/EdgeCases/NetworkEdgeCaseTests.swift`
  - File: `MessengerAITests/EdgeCases/MessageEdgeCaseTests.swift`
  - File: `MessengerAITests/EdgeCases/ErrorHandlingTests.swift`

**Test Coverage (Critical for Verification):**

**App Lifecycle Tests:**
- ✅ `testAppBackgrounding()` - Listeners pause correctly
- ✅ `testAppForegrounding()` - Listeners resume correctly
- ✅ `testUserStatusOnBackground()` - User marked offline
- ✅ `testUserStatusOnForeground()` - User marked online
- ✅ `testBackgroundWhileSending()` - Message completes in background
- ✅ `testBackgroundTimeLimit()` - Handle iOS background time limits
- ✅ `testAppTermination()` - Cleanup and data persistence
- ✅ `testForegroundSyncNewMessages()` - Load messages missed while away
- ✅ `testMultipleBackgroundForegr ound()` - Rapid state changes
- ✅ `testBackgroundTaskCompletion()` - Background tasks complete

**Network Edge Case Tests:**
- ✅ `testNetworkDropMidSend()` - Message queues if network drops
- ✅ `testNetworkFlapping()` - Rapid on/off transitions
- ✅ `testSlowNetwork()` - Handle timeouts gracefully
- ✅ `testNetworkTimeout()` - Retry after timeout
- ✅ `testPartialDataLoad()` - Handle incomplete downloads
- ✅ `testReconnectAfterLongOffline()` - Handle 8+ hour offline
- ✅ `testSimultaneousNetworkAndAppState()` - Both change together
- ✅ `testFirestoreConnectionLoss()` - Specific to Firestore
- ✅ `testAutoRetryWithBackoff()` - Exponential backoff works

**Message Edge Case Tests:**
- ✅ `testVeryLongMessage()` - 9000+ characters
- ✅ `testMessageWithOnlyEmoji()` - "😀😀😀"
- ✅ `testMessageWithManyNewlines()` - Handle formatting
- ✅ `testMessageWithSpecialCharacters()` - "<>&\"'"
- ✅ `testEmptyMessagePrevention()` - Cannot send empty
- ✅ `testWhitespaceOnlyMessage()` - Trim and prevent
- ✅ `testRapidMessaging()` - 10 messages in 1 second
- ✅ `testDuplicateMessagePrevention()` - Same content twice
- ✅ `testMessageRateLimiting()` - Max 20 messages per minute
- ✅ `testConcurrentMessageSends()` - Two messages at exact same time
- ✅ `testMessageWithLinks()` - URLs handled correctly
- ✅ `testMessageWithMentions()` - @username formatting
- ✅ `testVeryLongWord()` - No word-break issues
- ✅ `testRTLLanguages()` - Arabic, Hebrew support
- ✅ `testMixedLanguages()` - English + Arabic in one message

**Error Handling Tests:**
- ✅ `testFirestorePermissionError()` - Handle 403
- ✅ `testFirestoreNotFoundError()` - Handle 404
- ✅ `testFirestoreTimeoutError()` - Handle timeout
- ✅ `testAuthenticationExpired()` - Handle token expiration
- ✅ `testQuotaExceededError()` - Firestore quota exceeded
- ✅ `testNetworkUnavailableError()` - No internet
- ✅ `testInvalidDataError()` - Corrupted Firestore data
- ✅ `testUserFriendlyErrorMessages()` - No tech jargon
- ✅ `testErrorRetryMechanism()` - Retry button works
- ✅ `testErrorLogging()` - Errors logged for debugging
- ✅ `testMultipleSimultaneousErrors()` - Handle error queue
- ✅ `testRecoveryFromError()` - App continues after error

**Memory & Performance Edge Cases:**
- ✅ `testMemoryWarning()` - Handle low memory
- ✅ `testLargeConversationMemory()` - 1000+ messages
- ✅ `testConcurrentConversations()` - Multiple conversations open
- ✅ `testListenerMemoryLeaks()` - No retain cycles
- ✅ `testBackgroundMemoryCleanup()` - Release memory when backgrounded

**UI Edge Cases:**
- ✅ `testKeyboardOverlapsInput()` - Keyboard handling
- ✅ `testRotationHandling()` - Portrait ↔ Landscape
- ✅ `testDynamicTypeSupport()` - Accessibility text sizes
- ✅ `testDarkModeSupport()` - Dark mode rendering
- ✅ `testVoiceOverSupport()` - Accessibility labels
- ✅ `testTouchTargetSizes()` - Minimum 44x44pt

**Mock Requirements:**
- Mock UIApplication for app state
- Mock NWPathMonitor for network states
- Mock Firestore for various errors
- Use XCTest expectations for async tests

**Success Criteria:**
- Zero crashes in edge case scenarios
- All errors have user-friendly messages
- App recovers gracefully from all errors
- No memory leaks detected
- All accessibility requirements met

**Files Updated:**
- `App/AppDelegate.swift`
- `Services/NetworkMonitor.swift`
- `Views/Chat/MessageBubbleView.swift`
- `ViewModels/MessageInputViewModel.swift`
- `Views/Components/ErrorView.swift`

**Files Created:**
- `MessengerAITests/EdgeCases/AppLifecycleTests.swift`
- `MessengerAITests/EdgeCases/NetworkEdgeCaseTests.swift`
- `MessengerAITests/EdgeCases/MessageEdgeCaseTests.swift`
- `MessengerAITests/EdgeCases/ErrorHandlingTests.swift`

---

### PR #16: Phase 1 Integration Testing & Bug Fixes
**Branch:** `feature/phase1-testing`  
**Description:** Run all Phase 1 tests and fix bugs  
**Timeline:** Day 10

**Tasks:**
- [ ] Run all test scenarios from PRD (TEST-1.1 to TEST-1.9)
  - Update test file: `MessengerAITests/IntegrationTests.swift`
- [ ] Manual testing on physical device
  - Test authentication flow
  - Test real-time messaging
  - Test offline scenarios
  - Test edge cases
- [ ] Fix identified bugs
  - Create bug fix commits in this PR
- [ ] Performance optimization
  - Profile with Instruments
  - Optimize message rendering
  - Optimize Firestore queries
- [ ] UI/UX polish
  - Smooth animations
  - Loading states
  - Error states
- [ ] Code cleanup and documentation
  - Add inline comments
  - Update README with setup instructions
- [ ] Create Phase 1 demo video

**Files Updated:**
- Various files based on bugs found

**Files Created:**
- `MessengerAITests/IntegrationTests.swift`
- `README.md` (update with comprehensive setup guide)

---

## 🎯 Phase 2: AI Features

### PR #17: Cloud Functions Setup
**Branch:** `feature/cloud-functions-setup`  
**Description:** Set up Firebase Cloud Functions and OpenAI integration  
**Timeline:** Day 11

**Tasks:**
- [ ] Initialize Cloud Functions project
  - Run: `firebase init functions`
  - Select TypeScript
- [ ] Create Cloud Functions project structure
  - Directory: `CloudFunctions/functions/`
- [ ] Install dependencies
  - File: `CloudFunctions/functions/package.json`
  - Add: firebase-functions, firebase-admin, openai
- [ ] Configure TypeScript
  - File: `CloudFunctions/functions/tsconfig.json`
- [ ] Create main index file
  - File: `CloudFunctions/functions/src/index.ts`
  - Export all cloud functions
- [ ] Set up OpenAI API key in Firebase config
  - Run: `firebase functions:config:set openai.key="YOUR_KEY"`
- [ ] Create base cloud function structure
  - File: `CloudFunctions/functions/src/baseFunction.ts`
  - Error handling, authentication check, rate limiting
- [ ] Deploy hello world function to test
  - Run: `firebase deploy --only functions`
- [ ] Create AIService on iOS side
  - File: `Services/AIService.swift`
  - Methods to call cloud functions
- [ ] **Write unit tests**
  - File: `MessengerAITests/Services/AIServiceTests.swift`
  - File: `CloudFunctions/functions/test/baseFunction.test.ts`

**Test Coverage (Critical for Verification):**

**AIService Tests (Swift):**
- ✅ `testAIServiceInitialization()` - Service initializes correctly
- ✅ `testCallCloudFunctionSuccess()` - Successful API call
- ✅ `testCallCloudFunctionFailure()` - Handle function errors
- ✅ `testCallCloudFunctionTimeout()` - Handle timeouts
- ✅ `testCallCloudFunctionWithAuth()` - Auth token included
- ✅ `testCallCloudFunctionUnauthorized()` - Handle 401
- ✅ `testRateLimitHandling()` - Handle 429 rate limit
- ✅ `testRequestSerialization()` - Data encoded correctly
- ✅ `testResponseDeserialization()` - Data decoded correctly
- ✅ `testNetworkErrorHandling()` - No internet handling
- ✅ `testConcurrentRequests()` - Multiple requests simultaneously
- ✅ `testRequestCancellation()` - Can cancel ongoing request
- ✅ `testRetryMechanism()` - Auto-retry on transient errors

**Base Cloud Function Tests (TypeScript):**
- ✅ `testAuthenticationCheck()` - Rejects unauthenticated calls
- ✅ `testAuthenticatedCallSucceeds()` - Accepts authenticated calls
- ✅ `testRateLimitEnforcement()` - Blocks after limit exceeded
- ✅ `testRateLimitReset()` - Resets after time window
- ✅ `testErrorHandling()` - Returns proper error format
- ✅ `testInputValidation()` - Validates required parameters
- ✅ `testOpenAIKeyPresent()` - API key configured
- ✅ `testFirebaseAdminInitialization()` - Admin SDK initialized
- ✅ `testCORSHandling()` - CORS headers set correctly
- ✅ `testLoggingWorks()` - Console logs function calls

**Integration Tests:**
- ✅ `testEndToEndFunctionCall()` - iOS → Cloud Function → Response
- ✅ `testAuthTokenPropagation()` - Token reaches function
- ✅ `testErrorPropagationToiOS()` - Error message reaches iOS
- ✅ `testTimeoutEnforcement()` - Function times out correctly

**Mock Requirements:**
- Mock URLSession for AIService tests
- Mock Firebase Admin SDK for function tests
- Mock OpenAI API responses
- Use Firebase Functions emulator for local testing

**Success Criteria:**
- AIService can successfully call cloud functions
- Authentication works end-to-end
- Rate limiting prevents abuse
- Errors are handled gracefully
- All tests pass in CI/CD

**Files Created:**
- `CloudFunctions/functions/package.json`
- `CloudFunctions/functions/tsconfig.json`
- `CloudFunctions/functions/src/index.ts`
- `CloudFunctions/functions/src/baseFunction.ts`
- `Services/AIService.swift`
- `MessengerAITests/Services/AIServiceTests.swift`
- `CloudFunctions/functions/test/baseFunction.test.ts`

---

### PR #18: Summarization Cloud Function
**Branch:** `feature/summarization-backend`  
**Description:** Build conversation summarization backend  
**Timeline:** Day 12

**Tasks:**
- [ ] Create summarization cloud function
  - File: `CloudFunctions/functions/src/summarization.ts`
  - Accept: conversationID, messageRange
  - Call OpenAI API (GPT-4)
  - Return: keyPoints, decisions, actionItems, openQuestions
- [ ] Implement prompt engineering for summaries
  - Optimize prompt for remote team context
  - Test different prompts for quality
- [ ] Add response caching
  - Cache summaries in Firestore
  - Return cached if available
- [ ] Implement rate limiting
  - Limit: 20 requests/hour per user
  - Store counter in Firestore
- [ ] Add error handling and fallbacks
  - Handle OpenAI API errors
  - Timeout handling
- [ ] Deploy and test function
  - Run: `firebase deploy --only functions:summarizeConversation`
- [ ] **Write comprehensive unit tests**
  - File: `CloudFunctions/functions/test/summarization.test.ts`

**Test Coverage (Critical for Verification):**

**Summarization Function Tests:**
- ✅ `testSummarizeShortConversation()` - 10 messages
- ✅ `testSummarizeLongConversation()` - 50+ messages
- ✅ `testSummaryIncludesKeyPoints()` - Verify structure
- ✅ `testSummaryIncludesDecisions()` - Extract decisions
- ✅ `testSummaryIncludesActionItems()` - Extract action items
- ✅ `testSummaryIncludesOpenQuestions()` - Extract questions
- ✅ `testSummaryConciseness()` - < 30% of original length
- ✅ `testSummaryQuality()` - Captures main discussion
- ✅ `testCacheHit()` - Returns cached summary
- ✅ `testCacheMiss()` - Calls OpenAI when no cache
- ✅ `testCacheInvalidation()` - New messages invalidate cache
- ✅ `testRateLimitEnforcement()` - 20 requests/hour max
- ✅ `testRateLimitReset()` - Reset after hour
- ✅ `testOpenAIAPIError()` - Handle 500 errors
- ✅ `testOpenAITimeout()` - Handle timeouts
- ✅ `testInvalidInput()` - Handle missing conversationID
- ✅ `testEmptyConversation()` - Handle 0 messages
- ✅ `testUnauthenticatedRequest()` - Reject without auth
- ✅ `testUnauthorizedUser()` - User not in conversation

**Prompt Engineering Tests:**
- ✅ `testTechnicalDiscussionSummary()` - Engineering context
- ✅ `testDesignFeedbackSummary()` - Design context
- ✅ `testProductDecisionSummary()` - PM context
- ✅ `testMixedTopicSummary()` - Multiple topics
- ✅ `testSummaryLanguage()` - Professional tone
- ✅ `testSummaryBulletPoints()` - Formatted correctly

**Integration Tests:**
- ✅ `testEndToEndSummarization()` - Full flow
- ✅ `testFirestoreCachePersistence()` - Cache saves correctly
- ✅ `testFirestoreRateLimitStorage()` - Counter updates

**Mock Requirements:**
- Mock OpenAI API responses
- Mock Firestore for caching
- Mock Firebase Admin for auth
- Test with realistic conversation data

**Success Criteria:**
- Summaries capture 90%+ of key information
- Response time < 2 seconds (cached) or < 5 seconds (new)
- Cache hit rate > 70% in production
- Rate limiting prevents abuse
- All errors handled gracefully

**Files Created:**
- `CloudFunctions/functions/src/summarization.ts`
- `CloudFunctions/functions/test/summarization.test.ts`

**Files Updated:**
- `CloudFunctions/functions/src/index.ts`

---

### PR #19: Summarization Frontend
**Branch:** `feature/summarization-ui`  
**Description:** Build summary UI and integration  
**Timeline:** Day 13

**Tasks:**
- [ ] Create SummaryRepository
  - File: `Repositories/SummaryRepository.swift`
  - Methods: getSummary, requestSummary, cacheSummary
- [ ] Update AIService to call summarization function
  - Update: `Services/AIService.swift`
  - Add: summarizeConversation method
- [ ] Create SummaryView
  - File: `Views/AI/SummaryView.swift`
  - Display: key points, decisions, action items, open questions
  - Sections with collapsible content
  - "Dismiss" and "Save" buttons
- [ ] Add "Summarize" button to ChatView
  - Update: `Views/Chat/ChatView.swift`
  - Toolbar button
  - Show SummaryView as sheet
- [ ] Implement auto-trigger logic
  - Update: `ViewModels/ChatViewModel.swift`
  - Trigger when: 15+ messages unread AND user offline 6+ hours
  - Show prompt to view summary
- [ ] Add loading and error states
- [ ] Persist summaries for offline access
  - Store in Firestore and local cache
- [ ] **Write comprehensive integration tests**
  - File: `MessengerAITests/Integration/SummarizationIntegrationTests.swift`
  - File: `MessengerAITests/Repositories/SummaryRepositoryTests.swift`
  - File: `MessengerAIUITests/SummarizationUITests.swift`

**Test Coverage (Critical for Verification):**

**SummaryRepository Tests:**
- ✅ `testRequestSummary()` - Call AIService correctly
- ✅ `testGetSummaryFromCache()` - Return cached if available
- ✅ `testCacheSummary()` - Save to Firestore and local
- ✅ `testSummaryOfflineAccess()` - Load from local cache when offline
- ✅ `testSummaryCacheExpiration()` - Invalidate on new messages
- ✅ `testGetSummaryForNonExistentConversation()` - Handle error

**Integration Tests:**
- ✅ `testEndToEndSummarization()` - User request → Cloud Function → UI display
- ✅ `testManualSummaryTrigger()` - User taps "Summarize" button
- ✅ `testAutoSummaryTrigger()` - Auto-trigger on 15+ unread messages
- ✅ `testAutoTriggerAfter6Hours()` - Only trigger after 6+ hours offline
- ✅ `testSummaryDisplaysAllSections()` - Key points, decisions, actions, questions
- ✅ `testSummaryDismiss()` - Dismiss closes sheet
- ✅ `testSummarySave()` - Save persists to Firestore
- ✅ `testSummaryLoadingState()` - Shows spinner while generating
- ✅ `testSummaryErrorState()` - Shows error message on failure
- ✅ `testSummaryRetry()` - Retry button works after error
- ✅ `testSummaryCaching()` - Second request uses cache
- ✅ `testSummaryOfflineLoad()` - Can view cached summary offline
- ✅ `testMultipleSummariesForSameConversation()` - Different time ranges
- ✅ `testSummaryNavigation()` - Can navigate from summary to messages
- ✅ `testSummarySharing()` - Can copy/share summary

**UI Tests:**
- ✅ `testSummarizeButtonVisible()` - Button appears in toolbar
- ✅ `testSummarizeButtonTapped()` - Opens SummaryView
- ✅ `testSummaryViewLayout()` - All sections display correctly
- ✅ `testExpandCollapseSections()` - Sections expand/collapse
- ✅ `testSummaryViewDismiss()` - Dismiss button closes view
- ✅ `testSummaryViewSave()` - Save button works
- ✅ `testAutoPromptDisplay()` - Prompt shows for auto-trigger
- ✅ `testAutoPromptAccept()` - Accepting shows summary
- ✅ `testAutoPromptDismiss()` - Dismissing hides prompt

**Scenario Tests:**
- ✅ `testScenario_FirstTimeSummary()` - New conversation, no cache
- ✅ `testScenario_CachedSummary()` - Return from summary, use cache
- ✅ `testScenario_OfflineSummary()` - View summary while offline
- ✅ `testScenario_SummaryAfterLongAbsence()` - User away 8+ hours
- ✅ `testScenario_SummaryError()` - API fails, user retries

**Performance Tests:**
- ✅ `testSummaryGenerationTime()` - < 5 seconds for new
- ✅ `testCachedSummaryLoadTime()` - < 1 second for cached
- ✅ `testSummaryViewRenderTime()` - UI renders quickly

**Mock Requirements:**
- Mock AIService for unit tests
- Mock SummaryRepository for UI tests
- Use Firestore Emulator for integration tests
- Mock time/date for auto-trigger tests

**Success Criteria:**
- Summary accurately represents conversation
- UI is intuitive and responsive
- Auto-trigger works as specified
- Caching reduces API calls by 70%+
- Offline access works correctly

**Files Created:**
- `Repositories/SummaryRepository.swift`
- `Views/AI/SummaryView.swift`
- `MessengerAITests/Integration/SummarizationIntegrationTests.swift`
- `MessengerAITests/Repositories/SummaryRepositoryTests.swift`
- `MessengerAIUITests/SummarizationUITests.swift`

**Files Updated:**
- `Services/AIService.swift`
- `Views/Chat/ChatView.swift`
- `ViewModels/ChatViewModel.swift`

---

### PR #20: Clarity Assistant Cloud Function
**Branch:** `feature/clarity-backend`  
**Description:** Build clarity check backend  
**Timeline:** Day 14

**Tasks:**
- [ ] Create clarity check cloud function
  - File: `CloudFunctions/functions/src/clarity.ts`
  - Accept: messageContent, conversationContext
  - Call OpenAI API (GPT-4)
  - Return: clarityIssues, suggestedRevision, improvements
- [ ] Implement prompt engineering for clarity
  - Check for: vague pronouns, missing context, ambiguities
  - Suggest clarifying questions
- [ ] Add response caching
  - Cache suggestions for 5 minutes
  - Same message → return cached result
- [ ] Implement debouncing on server side
  - Don't process if same user sent request < 2 seconds ago
- [ ] Add rate limiting
  - Limit: 30 requests/hour per user
- [ ] Deploy and test function
  - Run: `firebase deploy --only functions:checkClarity`
- [ ] **Write comprehensive unit tests**
  - File: `CloudFunctions/functions/test/clarity.test.ts`

**Test Coverage (Critical for Verification):**
- ✅ `testDetectVaguePronouns()` - "it", "that", "this" without antecedent
- ✅ `testDetectMissingContext()` - Unclear references
- ✅ `testDetectAmbiguity()` - Multiple interpretations possible
- ✅ `testSuggestClarification()` - Provide specific improvements
- ✅ `testClearMessageNoSuggestions()` - No false positives
- ✅ `testCacheHit()` - Return cached result
- ✅ `testDebounceEnforcement()` - Block rapid requests
- ✅ `testRateLimitEnforcement()` - 30 requests/hour max
- ✅ `testTechnicalJargonDetection()` - Flag complex terms
- ✅ `testContextAwareness()` - Use conversation history
- ✅ `testEmptyMessageHandling()` - Reject empty input
- ✅ `testVeryLongMessageHandling()` - Handle 9000+ characters
- ✅ `testOpenAIAPIError()` - Handle failures gracefully

**Files Created:**
- `CloudFunctions/functions/src/clarity.ts`
- `CloudFunctions/functions/test/clarity.test.ts`

**Files Updated:**
- `CloudFunctions/functions/src/index.ts`

---

### PR #21: Clarity Assistant Frontend
**Branch:** `feature/clarity-ui`  
**Description:** Build clarity suggestion UI  
**Timeline:** Day 15

**Tasks:**
- [ ] Update AIService for clarity checks
  - Update: `Services/AIService.swift`
  - Add: checkClarity method
  - Implement client-side debouncing (2 seconds)
- [ ] Create ClaritySuggestionView
  - File: `Views/AI/ClaritySuggestionView.swift`
  - Display clarity issues as expandable card
  - Show suggested revision
  - "Accept", "Modify", "Dismiss" buttons
- [ ] Update MessageInputViewModel for clarity checks
  - Update: `ViewModels/MessageInputViewModel.swift`
  - Add: claritySuggestion property
  - Trigger check when user stops typing (debounced)
- [ ] Integrate ClaritySuggestionView into MessageInputView
  - Update: `Views/Chat/MessageInputView.swift`
  - Show suggestions inline above input field
  - Non-intrusive, dismissible
- [ ] Add "Accept suggestion" logic
  - Replace message text with suggested revision
- [ ] Handle loading and error states
- [ ] **Write comprehensive integration tests**
  - File: `MessengerAITests/Integration/ClarityIntegrationTests.swift`
  - File: `MessengerAIUITests/ClarityUITests.swift`

**Test Coverage (Critical for Verification):**
- ✅ `testClarityCheckTriggered()` - Check runs after 2 seconds
- ✅ `testDebounceWorks()` - Only runs after user stops typing
- ✅ `testClarityIssuesDisplay()` - Issues show in UI
- ✅ `testSuggestedRevisionDisplay()` - Revision shows correctly
- ✅ `testAcceptSuggestion()` - Replaces message text
- ✅ `testModifySuggestion()` - User can edit suggestion
- ✅ `testDismissSuggestion()` - Hides suggestion card
- ✅ `testNoSuggestionForClearMessage()` - Clear messages pass through
- ✅ `testMultipleIssuesDisplay()` - All issues shown
- ✅ `testRapidTypingNoCheck()` - Doesn't check while typing
- ✅ `testClearityCheckCaching()` - Same message uses cache
- ✅ `testErrorHandling()` - API error shows gracefully
- ✅ `testOfflineClarityCheck()` - Disabled when offline
- ✅ `testLoadingState()` - Shows checking indicator

**Files Created:**
- `Views/AI/ClaritySuggestionView.swift`
- `MessengerAITests/Integration/ClarityIntegrationTests.swift`
- `MessengerAIUITests/ClarityUITests.swift`

**Files Updated:**
- `Services/AIService.swift`
- `ViewModels/MessageInputViewModel.swift`
- `Views/Chat/MessageInputView.swift`

---

### PR #22: Action Items & Tone Analysis Cloud Functions
**Branch:** `feature/action-items-tone-backend`  
**Description:** Build action item extraction and tone analysis backends  
**Timeline:** Day 16

**Tasks:**
- [ ] Create action item extraction cloud function
  - File: `CloudFunctions/functions/src/actionItems.ts`
  - Accept: messageContent, conversationContext
  - Call OpenAI API (GPT-4o-mini for cost efficiency)
  - Return: description, assignedTo, dueDate
- [ ] Create tone analysis cloud function
  - File: `CloudFunctions/functions/src/toneAnalysis.ts`
  - Accept: messageContent, conversationContext, recipientRole
  - Call OpenAI API (GPT-4)
  - Return: toneWarning, alternativePhrasing, improvementSuggestions
- [ ] Implement prompt engineering for action items
  - Extract commitments, to-dos, assignments
  - Identify who's responsible and deadlines
- [ ] Implement prompt engineering for tone
  - Check for: terse language, potential rudeness, jargon
  - Consider recipient role (engineer, designer, PM)
- [ ] Add rate limiting for both functions
- [ ] Deploy functions
  - Run: `firebase deploy --only functions:extractActionItems,analyzeTone`
- [ ] **Write comprehensive unit tests**
  - File: `CloudFunctions/functions/test/actionItems.test.ts`
  - File: `CloudFunctions/functions/test/toneAnalysis.test.ts`

**Test Coverage (Critical for Verification):**

**Action Item Tests:**
- ✅ `testExtractExplicitCommitment()` - "I'll do X by Friday"
- ✅ `testExtractQuestionBasedAction()` - "Can you review Y?"
- ✅ `testExtractMultipleActions()` - Multiple items in one message
- ✅ `testIdentifyAssignee()` - Extract who's responsible
- ✅ `testIdentifyDeadline()` - Extract due date
- ✅ `testNoActionItemsInMessage()` - No false positives
- ✅ `testVagueCommitment()` - "I'll think about it" → no action
- ✅ `testTeamBasedAction()` - "We should..." → multiple assignees
- ✅ `testPastTenseNoAction()` - "I did X" → not an action item
- ✅ `testConditionalAction()` - "If X, then I'll do Y"

**Tone Analysis Tests:**
- ✅ `testDetectTerseness()` - "No." → warning
- ✅ `testDetectPotentialRudeness()` - Abrupt language
- ✅ `testDetectJargonForNonTech()` - Engineer → Designer jargon
- ✅ `testSuggestAlternativePhrasing()` - Provide better version
- ✅ `testNeutralToneNoWarning()` - No false positives
- ✅ `testPositiveToneNoWarning()` - Friendly messages pass
- ✅ `testRoleAwareness()` - Consider recipient role
- ✅ `testCriticalFeedbackHandling()` - Constructive criticism OK
- ✅ `testEmojiImpactOnTone()` - Emoji softens message
- ✅ `testContextAwareTone()` - Consider conversation history

**Files Created:**
- `CloudFunctions/functions/src/actionItems.ts`
- `CloudFunctions/functions/src/toneAnalysis.ts`
- `CloudFunctions/functions/test/actionItems.test.ts`
- `CloudFunctions/functions/test/toneAnalysis.test.ts`

**Files Updated:**
- `CloudFunctions/functions/src/index.ts`

---

### PR #23: Action Items & Tone Analysis Frontend
**Branch:** `feature/action-items-tone-ui`  
**Description:** Build UI for action items and tone suggestions  
**Timeline:** Day 16

**Tasks:**
- [ ] Create ActionItemRepository
  - File: `Repositories/ActionItemRepository.swift`
  - Methods: getActionItems, createActionItem, updateActionItem, deleteActionItem, markComplete
- [ ] Update AIService for action items and tone
  - Update: `Services/AIService.swift`
  - Add: extractActionItems, analyzeTone methods
- [ ] Create AIFeaturesViewModel
  - File: `ViewModels/AIFeaturesViewModel.swift`
  - Manage action items and tone suggestions
- [ ] Create ActionItemsView
  - File: `Views/AI/ActionItemsView.swift`
  - List of action items for conversation
  - Show: description, assignee, due date, completion status
  - Toggle to mark complete
  - Filter: all, open, completed
- [ ] Create ToneSuggestionView
  - File: `Views/AI/ToneSuggestionView.swift`
  - Show tone warning
  - Display alternative phrasing
  - "Apply" or "Dismiss" buttons
- [ ] Integrate action item extraction
  - Update: `Repositories/MessageRepository.swift`
  - Auto-extract action items after message sent
  - Store in Firestore subcollection
- [ ] Integrate tone analysis into MessageInputViewModel
  - Update: `ViewModels/MessageInputViewModel.swift`
  - Check tone when user pauses typing
  - Show ToneSuggestionView if issues detected
- [ ] Add action items button to ChatView
  - Update: `Views/Chat/ChatView.swift`
  - Show ActionItemsView as sheet
- [ ] **Write comprehensive integration tests**
  - File: `MessengerAITests/Integration/ActionItemsIntegrationTests.swift`
  - File: `MessengerAITests/Integration/ToneAnalysisIntegrationTests.swift`
  - File: `MessengerAITests/Repositories/ActionItemRepositoryTests.swift`
  - File: `MessengerAIUITests/ActionItemsUITests.swift`
  - File: `MessengerAIUITests/ToneAnalysisUITests.swift`

**Test Coverage (Critical for Verification):**

**Action Item Integration Tests:**
- ✅ `testAutoExtractActionItems()` - Extract on message send
- ✅ `testActionItemsDisplayInList()` - Show in ActionItemsView
- ✅ `testMarkActionItemComplete()` - Toggle completion
- ✅ `testActionItemWithAssignee()` - Display assignee
- ✅ `testActionItemWithDeadline()` - Display due date
- ✅ `testFilterOpenActionItems()` - Filter works
- ✅ `testFilterCompletedActionItems()` - Filter works
- ✅ `testActionItemPersistence()` - Saves to Firestore
- ✅ `testActionItemOfflineAccess()` - View offline
- ✅ `testMultipleActionItemsInMessage()` - All extracted
- ✅ `testNoActionItemsInMessage()` - No false extractions
- ✅ `testDeleteActionItem()` - User can delete
- ✅ `testEditActionItem()` - User can edit description
- ✅ `testActionItemNotifications()` - Remind before deadline

**Tone Analysis Integration Tests:**
- ✅ `testToneCheckTriggered()` - Check runs on pause
- ✅ `testToneWarningDisplay()` - Warning shows in UI
- ✅ `testAlternativePhrasing()` - Suggestion provided
- ✅ `testApplyToneSuggestion()` - Replaces text
- ✅ `testDismissToneSuggestion()` - Hides warning
- ✅ `testNoToneWarningForNeutral()` - No false positives
- ✅ `testRoleAwareTone()` - Different for engineer/designer/PM
- ✅ `testToneCheckCaching()` - Same message uses cache
- ✅ `testToneCheckDebounce()` - Only after 2 seconds
- ✅ `testToneAndClarityTogether()` - Both can trigger

**Repository Tests:**
- ✅ `testCreateActionItem()` - Save to Firestore
- ✅ `testGetActionItems()` - Retrieve for conversation
- ✅ `testUpdateActionItem()` - Modify existing
- ✅ `testDeleteActionItem()` - Remove from Firestore
- ✅ `testMarkComplete()` - Update completion status
- ✅ `testGetOpenActionItems()` - Query incomplete only
- ✅ `testGetCompletedActionItems()` - Query complete only
- ✅ `testActionItemRealTimeUpdates()` - Listener works

**UI Tests:**
- ✅ `testActionItemsButtonVisible()` - Button in toolbar
- ✅ `testActionItemsListDisplay()` - Items show correctly
- ✅ `testToggleCompletion()` - Tap checkbox works
- ✅ `testFilterButtons()` - All/Open/Complete filters
- ✅ `testToneWarningDisplay()` - Warning card shows
- ✅ `testToneSuggestionAccept()` - Apply button works
- ✅ `testToneSuggestionDismiss()` - Dismiss button works

**Success Criteria:**
- Action items extracted with 85%+ accuracy
- Tone analysis < 5% false positive rate
- UI responsive and non-intrusive
- All data persists correctly

**Files Created:**
- `Repositories/ActionItemRepository.swift`
- `ViewModels/AIFeaturesViewModel.swift`
- `Views/AI/ActionItemsView.swift`
- `Views/AI/ToneSuggestionView.swift`
- `MessengerAITests/Integration/ActionItemsIntegrationTests.swift`
- `MessengerAITests/Integration/ToneAnalysisIntegrationTests.swift`
- `MessengerAITests/Repositories/ActionItemRepositoryTests.swift`
- `MessengerAIUITests/ActionItemsUITests.swift`
- `MessengerAIUITests/ToneAnalysisUITests.swift`

**Files Updated:**
- `Services/AIService.swift`
- `Repositories/MessageRepository.swift`
- `ViewModels/MessageInputViewModel.swift`
- `Views/Chat/ChatView.swift`

---

### PR #24: AI Features Integration & Polish
**Branch:** `feature/ai-integration-polish`  
**Description:** Integrate all AI features and polish UX  
**Timeline:** Day 17

**Tasks:**
- [ ] Run all Phase 2 test scenarios (TEST-2.1 to TEST-2.12)
  - Update: `MessengerAITests/AIFeaturesIntegrationTests.swift`
- [ ] Optimize API call patterns
  - Reduce unnecessary calls
  - Improve caching strategy
- [ ] Add cost monitoring dashboard
  - File: `Views/Debug/CostMonitorView.swift`
  - Track: API calls, Firestore reads/writes, costs
  - Only visible in debug builds
- [ ] Polish AI feature UI
  - Consistent design language
  - Smooth animations
  - Clear loading states
- [ ] Add onboarding for AI features
  - First-time tooltips
  - Feature discovery
- [ ] Update Firestore security rules for AI data
  - Update: `CloudFunctions/firestore.rules`
  - Secure action items and summaries
- [ ] Write comprehensive AI feature tests
  - File: `MessengerAITests/AIFeaturesIntegrationTests.swift`
- [ ] Documentation
  - Document AI prompts
  - Document cost optimization strategies

**Files Created:**
- `Views/Debug/CostMonitorView.swift`
- `MessengerAITests/AIFeaturesIntegrationTests.swift`

**Files Updated:**
- `CloudFunctions/firestore.rules`
- Various UI files for polish

---

## 🎯 Phase 3: Final Testing & Submission

### PR #25: Comprehensive Testing & Bug Fixes
**Branch:** `feature/final-testing`  
**Description:** End-to-end testing and bug fixing  
**Timeline:** Day 18-19

**Tasks:**
- [ ] Run all test scenarios from PRD
  - Phase 1 tests (TEST-1.1 to TEST-1.9)
  - Phase 2 tests (TEST-2.1 to TEST-2.12)
- [ ] Manual testing on physical device
  - iPhone (different models)
  - Different iOS versions
- [ ] Performance testing
  - Battery usage
  - Memory leaks
  - Network usage
  - App launch time
- [ ] Security audit
  - Review Firestore security rules
  - Review API key management
  - Check for data leaks
- [ ] Accessibility testing
  - VoiceOver support
  - Dynamic type support
  - Color contrast
- [ ] Fix all identified bugs
  - Create individual commits for each bug
- [ ] Load testing
  - Test with 100+ messages
  - Test with multiple conversations
- [ ] Write performance tests
  - File: `MessengerAITests/PerformanceTests.swift`

**Files Updated:**
- Various files based on bugs found

**Files Created:**
- `MessengerAITests/PerformanceTests.swift`

---

### PR #26: UI/UX Polish & Documentation
**Branch:** `feature/final-polish`  
**Description:** Final polish and documentation  
**Timeline:** Day 20

**Tasks:**
- [ ] UI/UX final polish
  - Consistent spacing and padding
  - Smooth animations
  - Haptic feedback
  - Loading skeletons
- [ ] Add app icon and launch screen
  - File: `Resources/Assets.xcassets/AppIcon.appiconset/`
  - File: `Views/LaunchScreen.storyboard`
- [ ] Create user-facing documentation
  - File: `USERGUIDE.md`
  - How to use app
  - AI features explanation
- [ ] Update README with comprehensive setup guide
  - Update: `README.md`
  - Prerequisites
  - Installation steps
  - Firebase setup
  - Cloud Functions deployment
  - Sweetpad commands
- [ ] Create architecture documentation
  - File: `ARCHITECTURE.md`
  - System design
  - Data flow
  - Tech stack rationale
- [ ] Create demo video
  - Show key features
  - Demonstrate AI capabilities
- [ ] Code cleanup
  - Remove debug code
  - Remove unused imports
  - Consistent code style
- [ ] Final SwiftLint run and fixes

**Files Created:**
- `USERGUIDE.md`
- `ARCHITECTURE.md`
- `Resources/Assets.xcassets/AppIcon.appiconset/` (multiple image files)
- `Views/LaunchScreen.storyboard`

**Files Updated:**
- `README.md`
- Various files for cleanup

---

### PR #27: Production Deployment & Submission
**Branch:** `feature/production-deployment`  
**Description:** Deploy to production and submit  
**Timeline:** Day 21

**Tasks:**
- [ ] Final code review
  - Review all code
  - Check for security issues
  - Verify best practices
- [ ] Update Firebase project to production
  - Create production Firebase project
  - Update `GoogleService-Info.plist`
- [ ] Deploy Cloud Functions to production
  - Run: `firebase use production`
  - Run: `firebase deploy --only functions`
- [ ] Update Firestore security rules for production
  - Run: `firebase deploy --only firestore:rules`
- [ ] Set up Firebase Analytics
  - Track key events
  - Monitor crashes
- [ ] Create release build
  - Archive app
  - Test release build thoroughly
- [ ] Prepare submission materials
  - Screenshots
  - App description
  - Demo video
  - Privacy policy
- [ ] Submit project
  - Push final code to GitHub
  - Tag release: v1.0.0
  - Create release notes
- [ ] Post-submission monitoring
  - Monitor Firebase console
  - Monitor OpenAI API usage
  - Monitor costs

**Files Updated:**
- `Resources/GoogleService-Info.plist` (production version)
- `README.md` (add production setup)

**Files Created:**
- `CHANGELOG.md`
- `PRIVACY.md`

---

## 📊 Summary Statistics

**Total PRs:** 27
**Total Timeline:** 21 Days
**Phase Breakdown:**
- Phase 0 (Setup): 5 PRs (Days 1-2) - ✅ 100% Complete
- Phase 1 (Messaging): 11 PRs (Days 3-10) - ⏳ 0% Complete
- Phase 2 (AI Features): 8 PRs (Days 11-17) - ⏳ 0% Complete
- Phase 3 (Testing & Deployment): 3 PRs (Days 18-21) - ⏳ 0% Complete

**Total Files to Create:** ~100+
**Total Files to Update:** ~30+

**Current Progress:**
- PRs Complete: 1 of 27 (4%)
- Days Used: 2 of 21 (10%)
- Phase 0: ✅ Complete
- Phase 1: 🎯 Starting with PR #2

---

## 🔄 Git Workflow

### Branch Naming Convention
```
feature/<feature-name>
bugfix/<bug-description>
hotfix/<urgent-fix>
```

### Commit Message Convention
```
type(scope): description

Types: feat, fix, docs, style, refactor, test, chore
Examples:
- feat(auth): add login functionality
- fix(messaging): resolve offline sync issue
- docs(readme): update setup instructions
```

### PR Template
```markdown
## Description
[Description of changes]

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Refactoring
- [ ] Documentation

## Testing
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] Tested on physical device

## Files Changed
- List of files modified

## Related Issues
Closes #[issue number]
```

---

## 🧪 Testing Checklist (Per PR)

Before merging each PR:
- [ ] All unit tests pass
- [ ] SwiftLint passes with no warnings
- [ ] Code compiles without errors
- [ ] Manual testing completed
- [ ] Code reviewed by at least one person
- [ ] Documentation updated
- [ ] No merge conflicts

---

## 📝 Development Notes

### Build & Run
- **Sweetpad Extension:** Primary method - `Cmd+Shift+B` to build, `Cmd+R` to run
- **XcodeGen:** Generate project with `npm run xcode:generate`
- **Hot Reload:** InjectionNext for instant UI updates (no rebuild needed)
- **Linting:** Auto-fix with `npm run lint:fix` before commits

### Firebase
- **Functions:** Deploy with `npm run functions:deploy`
- **Rules:** Deploy with `npm run firebase:deploy`
- **Emulators:** Local testing with `npm run firebase:emulators`
- **Logs:** View function logs with `npm run functions:logs`

### Code Quality Requirements
- **Zero SwiftLint violations** - Every file must pass
- **@MainActor on ViewModels** - Enforced by SwiftLint
- **Firebase listener cleanup** - Required in deinit
- **Proper file headers** - Required on all Swift files
- **Hot reload support** - Add to all views during development

### Testing Strategy
- **Unit Tests:** For ViewModels, Repositories, Services
- **Integration Tests:** For complete user flows
- **UI Tests:** For critical user journeys
- **Performance Tests:** For rendering and loading
- **Firebase Emulator:** For local backend testing

### Key Architectural Decisions
- **MVVM** (NOT VIPER) - Simpler for SwiftUI
- **Repository Pattern** - Protocol-based for testability
- **@MainActor** - All ViewModels for thread safety
- **No Package.swift** - XcodeGen manages SPM dependencies
- **Cursor Rules** - Modular .mdc files, not single .cursorrules

### Resources
- Workflow inspired by: https://danielraffel.me/2025/04/01/developing-ios-apps-in-cursor-with-sweetpad-yes-it-works/
- Memory Bank system for AI context persistence
- Cursor Masterclass patterns (Rudrank Riyam & Ray Fernando)

---

**Last Updated:** October 23, 2025  
**Document Owner:** Gauntlet AI Team  
**Status:** Phase 0 Complete, PR #2 Ready to Execute