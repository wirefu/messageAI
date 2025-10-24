# Firebase Emulator Testing Guide
**Date:** October 23, 2025  
**Status:** All PRs #2-7 Complete - Ready to Test!

---

## ✅ What's Running

1. **Firebase Emulator Suite** 🔥
   - Emulator UI: http://localhost:4000
   - Auth Emulator: localhost:9099
   - Firestore Emulator: localhost:8080

2. **MessengerAI App** 📱
   - Running in iPhone 17 Simulator
   - Connected to Firebase Emulator
   - Full auth flow ready to test!

---

## 🧪 Test Authentication Flow

### Test 1: Sign Up New User

**Steps:**
1. Look at simulator - you should see Login screen
2. Tap "**Sign Up**" at the bottom
3. Fill in:
   - Display Name: `Test User`
   - Email: `test@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
4. Tap blue "**Create Account**" button

**Expected:**
- ✅ Account created in Firebase Emulator
- ✅ You see "Messages" screen with "No Conversations" empty state
- ✅ Profile button (top-left) shows your name
- ✅ Console shows: "🔥 Using Firebase Emulator"

**Verify in Emulator UI:**
1. Go to http://localhost:4000
2. Click "**Authentication**" tab
3. You should see your test user!

---

### Test 2: Sign Out

**Steps:**
1. In simulator, tap **profile button** (person icon, top-left)
2. See menu with your name and email
3. Tap "**Sign Out**" (red)

**Expected:**
- ✅ Taken back to Login screen
- ✅ Ready to login again

---

### Test 3: Login

**Steps:**
1. On Login screen, enter:
   - Email: `test@example.com`
   - Password: `password123`
2. Tap blue "**Login**" button

**Expected:**
- ✅ Successfully authenticated
- ✅ Back to "Messages" screen
- ✅ See your profile in menu

---

### Test 4: Conversation List

**Steps:**
1. After logging in, you should see:
   - "**Messages**" title at top
   - "No Conversations" empty state
   - "Start a conversation..." message
   - Blue "**New Conversation**" button
   - **+** button in top-right
   - **Profile** button in top-left

2. Tap **+ button** or "New Conversation" button

**Expected:**
- ✅ "New Conversation" sheet slides up
- ✅ "No Users Found" (no other users yet)
- ✅ Can tap "Cancel" to dismiss

---

### Test 5: Create Multiple Users (Advanced)

To test conversations, you need 2 users:

**Steps:**
1. Sign out
2. Sign up as: `user2@example.com`
3. Sign out
4. Login as: `test@example.com`
5. Try creating conversation (still won't show user2 - need user listing feature)

**Note:** Full conversation testing requires PR #8 (Message Repository) and user listing feature.

---

## 🔍 Verify in Firebase Emulator UI

**Open:** http://localhost:4000

**Check Authentication Tab:**
- See all created users
- Verify emails
- Check UIDs

**Check Firestore Tab:**
- See `users` collection
- See user documents
- Verify data structure

---

## ✅ What Works Now

- ✅ Sign up with email/password
- ✅ Login with credentials
- ✅ Sign out
- ✅ See conversation list (empty for now)
- ✅ Navigation between screens
- ✅ Real-time validation
- ✅ Error handling
- ✅ All data saved in emulator

---

## 🎯 What's Next

**After testing:**
- PR #8-10: Message Repository & Chat UI
- PR #11-13: Offline Support
- PR #14-16: Polish & Integration Testing
- Then: Phase 2 AI Features!

---

## 🐛 Troubleshooting

**Emulator not responding:**
```bash
# Stop emulators
pkill -f firebase

# Restart
npx firebase emulators:start --only auth,firestore
```

**App not connecting:**
- Check console for "🔥 Using Firebase Emulator" message
- Verify emulator UI at http://localhost:4000
- Rebuild app if needed

**Clear emulator data:**
```bash
# Stop emulators and clear data
npx firebase emulators:start --only auth,firestore --import=./emulator-data --export-on-exit
```

---

**Happy Testing!** 🎉

