# MessengerAI

An intelligent communication platform designed for remote teams, featuring AI-powered messaging capabilities including smart summarization, clarity assistance, action item extraction, and tone analysis.

## 🎯 Project Overview

MessengerAI enables remote teams to communicate with the clarity of synchronous meetings while maintaining the flexibility of asynchronous work. Built with Swift, SwiftUI, Firebase, and OpenAI.

**Target Users:** Remote software engineers, product designers, and product managers

## 🏗️ Architecture

- **Frontend:** Swift + SwiftUI (iOS 16+)
- **Backend:** Firebase (Auth, Firestore, Cloud Functions, Storage)
- **AI Integration:** OpenAI API (GPT-4) via Cloud Functions
- **Pattern:** MVVM (Model-View-ViewModel)
- **State Management:** Combine Framework

## 📁 Project Structure

```
MessageAI/
├── MessageAI/
│   ├── App/                    # App entry point and configuration
│   ├── Models/                 # Data models (User, Message, Conversation, etc.)
│   ├── Views/                  # SwiftUI views
│   │   ├── Authentication/
│   │   ├── Conversations/
│   │   ├── Chat/
│   │   ├── AI/
│   │   └── Components/
│   ├── ViewModels/            # MVVM view models
│   ├── Services/              # Business logic services
│   ├── Repositories/          # Data access layer
│   ├── Utilities/             # Helper functions and extensions
│   └── Resources/             # Assets, plists, etc.
│
├── MessageAITests/            # Unit and integration tests
├── MessageAIUITests/          # UI tests
├── CloudFunctions/            # Firebase Cloud Functions (Node.js/TypeScript)
└── Package.swift              # Swift Package Manager dependencies
```

## ✨ Features

### Phase 1: Core Messaging (MVP)
- ✅ Email/password authentication
- ✅ Real-time 1:1 messaging
- ✅ Message delivery and read receipts
- ✅ Typing indicators
- ✅ Offline support with message queue
- ✅ Message history with pagination
- ✅ Search functionality
- ✅ Online/offline status

### Phase 2: AI Features
- 🤖 **Smart Summarization:** Auto-summarize long conversations
- 💡 **Clarity Assistant:** Pre-send suggestions to improve message clarity
- ✅ **Action Item Extraction:** Automatically identify to-dos and commitments
- 🎯 **Tone Analysis:** Detect and suggest improvements for message tone

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+** with iOS 16+ SDK
- **Swift 5.9+**
- **Node.js 18+** (for Cloud Functions)
- **Firebase CLI:** `npm install -g firebase-tools`
- **CocoaPods** or **Swift Package Manager**
- **Sweetpad** (optional): For CLI automation

### Quick Setup (Automated)

**One-command setup:**
```bash
./scripts/setup.sh
```

This will automatically:
- Install Homebrew (if needed)
- Install XcodeGen, SwiftLint, Firebase CLI
- Install Node.js dependencies
- Generate Xcode project
- Run SwiftLint check

### Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/messageai.git
   cd messageai
   ```

2. **Install development tools**
   ```bash
   brew install xcodegen swiftlint
   npm install -g firebase-tools
   ```

3. **Install project dependencies**
   ```bash
   npm install
   npm run xcode:generate
   ```

4. **Firebase Setup**
   ```bash
   # Login to Firebase
   firebase login
   
   # Select your Firebase project
   firebase use --add
   
   # Deploy backend
   npm run functions:deploy
   firebase deploy --only firestore:rules
   ```

5. **Download Firebase Configuration**
   - Go to Firebase Console → Project Settings
   - Download `GoogleService-Info.plist`
   - Place it in `MessageAI/MessageAI/Resources/`

6. **Open in Xcode or Cursor**
   ```bash
   open MessageAI.xcodeproj
   # Or use Sweetpad in Cursor:
   # Cmd + Shift + B to build
   ```

### Running the App

**Option 1: Xcode**
1. Select your target device/simulator
2. Press `Cmd + R` to build and run

**Option 2: Cursor with Sweetpad**
- `Cmd + Shift + B` to build
- Or use npm scripts:

```bash
npm run build        # Build app
npm run test         # Run tests
npm run lint         # Check code quality
npm run lint:fix     # Auto-fix lint issues
```

**Option 3: Helper Scripts**
```bash
./scripts/run-tests.sh              # Run tests with coverage
./scripts/check-quality.sh          # Run code quality checks
./scripts/clean.sh                  # Clean build artifacts
```

## 🧪 Testing

### Run Unit Tests

**Quick way:**
```bash
./scripts/run-tests.sh
```

**With options:**
```bash
./scripts/run-tests.sh --device "iPhone 15" --os "17.2"
./scripts/run-tests.sh --no-coverage       # Skip coverage
./scripts/run-tests.sh --verbose           # Show detailed output
```

**Manual:**
```bash
# In Xcode: Cmd + U
# Or via command line:
npm run test
```

### Code Quality

**Check everything:**
```bash
./scripts/check-quality.sh
```

This checks:
- SwiftLint violations (strict mode)
- Large files (>1000 lines)
- TODO/FIXME comments
- Print statements
- Force unwrapping
- Test coverage ratio

### CI/CD

All PRs automatically run:
- ✅ SwiftLint (strict mode)
- ✅ Unit tests with coverage
- ✅ Build verification
- ✅ PR format checks

See `.github/workflows/` for GitHub Actions configuration.

## 📊 Development Workflow

### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Urgent production fixes

### Commit Convention
```
type(scope): description

Types: feat, fix, docs, style, refactor, test, chore
Examples:
- feat(auth): add login functionality
- fix(messaging): resolve offline sync issue
- docs(readme): update setup instructions
```

### Pull Request Process
1. Create feature branch from `develop`
2. Implement feature with tests
3. Run SwiftLint: `swiftlint`
4. Ensure all tests pass
5. Create PR with description and screenshots
6. Request code review
7. Merge after approval

## 🔒 Security

- Firebase security rules enforce data access control
- OpenAI API keys stored securely in Firebase Functions config
- User authentication required for all operations
- No sensitive data in client code

## 📈 Monitoring

- **Firebase Analytics:** Track user behavior and feature usage
- **Firebase Crashlytics:** Monitor app stability
- **Firebase Performance Monitoring:** Track app performance
- **Cloud Functions Logs:** Monitor backend operations

## 🔧 Troubleshooting

### Common Issues

**Build Errors:**
- Clean build folder: `Cmd + Shift + K`
- Reset package dependencies: `File → Packages → Reset Package Caches`

**Firebase Connection Issues:**
- Verify `GoogleService-Info.plist` is correctly placed
- Check Firebase project configuration in console

**Cloud Functions Not Working:**
- Verify functions are deployed: `firebase functions:list`
- Check function logs: `firebase functions:log`

## 📚 Documentation

- [Product Requirements Document](prd.md) - Detailed feature specifications
- [Task List](tasks.md) - Development roadmap and PR breakdown
- [Architecture Guide](ARCHITECTURE.md) - System design and patterns (coming soon)
- [User Guide](USERGUIDE.md) - End-user documentation (coming soon)

## 🤝 Contributing

This is currently a private project for the Gauntlet AI team. For questions or suggestions, please contact the project maintainers.

## 📄 License

Copyright © 2025 Gauntlet AI. All rights reserved.

## 🙏 Acknowledgments

- Firebase for backend infrastructure
- OpenAI for AI capabilities
- SwiftUI community for resources and inspiration

---

**Version:** 1.0.0  
**Last Updated:** October 23, 2025  
**Maintained by:** Gauntlet AI Team

