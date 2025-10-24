# Manual Test Guide - PRs #2-7
**Date:** October 23, 2025  
**Tester:** ___________  
**Simulator:** iPhone 17  
**Firebase:** Emulator Mode

---

## 🔧 Test Environment Setup

### Prerequisites Check:
- [ ] iPhone 17 Simulator is running
- [ ] MessengerAI app is installed and running
- [ ] Firebase Emulator UI open at http://localhost:4000
- [ ] You have test credentials ready

### Test Account:
**Email:** test@messengerai.com  
**Password:** password123

---

## 📋 Test Suite 1: Authentication Flow (PR #5)

### Test 1.1: Initial App State
**Objective:** Verify app launches correctly

**Steps:**
1. Look at the simulator
2. Observe what screen is displayed

**Expected Results:**
- [ ] Login screen appears
- [ ] "Welcome Back" title visible
- [ ] "Sign in to continue messaging" subtitle visible
- [ ] Email and Password fields visible
- [ ] Login button is GRAY (disabled - empty fields)
- [ ] "Don't have an account? Sign Up" link visible
- [ ] App icon at top (blue messaging bubbles)

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 1.2: Login with Test Account
**Objective:** Verify authentication works with Firebase Emulator

**Steps:**
1. Tap on Email field
2. Type: `test@messengerai.com`
3. Tap on Password field  
4. Type: `password123`
5. Observe Login button
6. Tap Login button
7. Wait for response

**Expected Results:**
- [ ] Email field accepts input
- [ ] Password shows dots (••••••••••••)
- [ ] Login button turns BLUE (enabled) after filling both fields
- [ ] Tapping Login shows loading spinner briefly
- [ ] Login succeeds
- [ ] Screen transitions to "Messages" screen
- [ ] Navigation bar shows "Messages" title
- [ ] Profile button visible (top-left)
- [ ] New conversation button visible (top-right)

**Verify in Emulator UI:**
1. Open http://localhost:4000
2. Click "Authentication" tab
3. [ ] Your test user is listed
4. [ ] Email shows: test@messengerai.com

**Verify in Console:**
- [ ] Console shows: "🔥 Using Firebase Emulator"
- [ ] Console shows: "✅ Firebase configured successfully"

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 1.3: Password Visibility Toggle
**Objective:** Verify password show/hide works

**Steps:**
1. If not on login screen, sign out first
2. Type any password in password field
3. Tap the EYE icon on the right side of password field
4. Observe password
5. Tap eye icon again

**Expected Results:**
- [ ] Initially password shows dots (••••••)
- [ ] After tapping eye: password shows as plain text
- [ ] Eye icon changes to "eye with slash"
- [ ] Tapping again: back to dots
- [ ] Eye icon changes back to regular eye

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 1.4: Email Validation
**Objective:** Verify real-time email validation

**Steps:**
1. Clear email field if filled
2. Type: `invalidemail` (no @ symbol)
3. Type any password
4. Observe Login button

5. Clear email field
6. Type: `test@example.com`
7. Observe Login button

**Expected Results:**
- [ ] With invalid email: Button stays GRAY (disabled)
- [ ] With valid email: Button turns BLUE (enabled)
- [ ] Validation happens immediately (real-time)

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 1.5: Navigate to Sign Up
**Objective:** Verify navigation between auth screens

**Steps:**
1. On Login screen, tap "**Sign Up**" link at bottom
2. Observe transition
3. Verify new screen content
4. Tap "**Login**" link at bottom
5. Observe transition back

**Expected Results:**
- [ ] Screen slides LEFT smoothly to Sign Up
- [ ] Sign Up screen shows "Create Account" title
- [ ] Sign Up screen shows 4 fields (Name, Email, Password, Confirm)
- [ ] Tapping Login: screen slides RIGHT back
- [ ] Smooth animations, no lag

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 1.6: Sign Up Validation
**Objective:** Verify sign up form validation

**Steps:**
1. Navigate to Sign Up screen
2. Type Display Name: `T` (1 character)
3. Type Email: `test2@example.com`
4. Type Password: `pass` (short)
5. Observe button and warnings

6. Change Password to: `password123`
7. Type Confirm Password: `password124` (doesn't match)
8. Observe warnings

9. Fix Confirm Password to: `password123`
10. Observe button

**Expected Results:**
- [ ] With short password: RED warning "Password must be at least 8 characters"
- [ ] Button stays GRAY
- [ ] With mismatched passwords: RED warning "Passwords don't match"
- [ ] Button stays GRAY
- [ ] When all valid: Warnings disappear, button turns BLUE
- [ ] Button only enables when ALL fields are valid

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 1.7: Create New Account via UI
**Objective:** Verify sign up creates account in emulator

**Steps:**
1. On Sign Up screen, fill in:
   - Display Name: `Test User 2`
   - Email: `user2@messengerai.com`
   - Password: `password123`
   - Confirm Password: `password123`
2. Tap "Create Account" button
3. Wait for response
4. Observe result

**Expected Results:**
- [ ] Loading spinner appears briefly
- [ ] Account created successfully
- [ ] Transitions to "Messages" screen
- [ ] User is authenticated

**Verify in Emulator UI:**
1. Refresh http://localhost:4000
2. Click "Authentication" tab
3. [ ] TWO users now listed (test@messengerai.com AND user2@messengerai.com)

4. Click "Firestore" tab
5. Click "users" collection
6. [ ] TWO user documents exist

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 1.8: Sign Out
**Objective:** Verify sign out works correctly

**Steps:**
1. While authenticated and on Messages screen
2. Tap profile button (person icon, top-left)
3. Observe menu
4. Tap "Sign Out" (red text)
5. Observe result

**Expected Results:**
- [ ] Menu appears showing:
  - Your display name
  - Your email  
  - Divider line
  - "Sign Out" option in red
- [ ] Tapping Sign Out returns to Login screen
- [ ] You're logged out (can't go back to Messages)

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

## 📋 Test Suite 2: Conversation List (PR #7)

### Test 2.1: Empty Conversation List
**Objective:** Verify empty state displays correctly

**Steps:**
1. Login with: test@messengerai.com
2. You should be on Messages screen
3. Observe the screen content

**Expected Results:**
- [ ] "Messages" navigation title at top
- [ ] Empty state icon (messaging bubbles) visible
- [ ] "No Conversations" title
- [ ] "Start a conversation to begin messaging..." message
- [ ] Blue "New Conversation" button
- [ ] **+** button in top-right corner
- [ ] Profile button in top-left corner

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 2.2: New Conversation Sheet
**Objective:** Verify new conversation UI appears

**Steps:**
1. On Messages screen, tap **+** button (top-right)
2. Observe what appears
3. Observe content
4. Tap "Cancel"
5. Repeat by tapping blue "New Conversation" button

**Expected Results:**
- [ ] Sheet slides up from bottom
- [ ] "New Conversation" title
- [ ] Search bar at top
- [ ] Empty state: "No Users Found"
- [ ] Message: "No other users available..."
- [ ] Cancel button dismisses sheet
- [ ] Both + button and blue button work the same

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 2.3: Profile Menu
**Objective:** Verify profile menu displays user info

**Steps:**
1. Tap profile button (person icon, top-left)
2. Observe menu content
3. Don't sign out yet

**Expected Results:**
- [ ] Menu shows your display name ("Test User")
- [ ] Menu shows your email (test@messengerai.com)
- [ ] Divider line
- [ ] "Sign Out" option with icon
- [ ] Menu is styled correctly

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 2.4: Pull to Refresh
**Objective:** Verify pull-to-refresh works (even with empty list)

**Steps:**
1. On Messages screen (empty conversations)
2. Pull down on the screen
3. Observe refresh indicator
4. Release

**Expected Results:**
- [ ] Refresh spinner appears
- [ ] Spinner disappears after refresh
- [ ] No crash
- [ ] List remains empty (correct - no conversations yet)

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

## 📋 Test Suite 3: UI Polish & Accessibility

### Test 3.1: Dark Mode Support
**Objective:** Verify app works in dark mode

**Steps:**
1. On your Mac, change system to Dark Mode:
   - Settings → Appearance → Dark
2. Observe app in simulator
3. Navigate through all screens (Login, Sign Up, Messages)
4. Change back to Light Mode
5. Observe again

**Expected Results:**
- [ ] All text is readable in Dark Mode
- [ ] Colors adapt appropriately
- [ ] No white text on white background
- [ ] No black text on black background
- [ ] Buttons visible in both modes
- [ ] Transitions smooth

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 3.2: Keyboard Handling
**Objective:** Verify keyboard doesn't block UI

**Steps:**
1. On Login screen, tap email field
2. Observe keyboard
3. Tap outside the text fields
4. Observe keyboard

5. On Sign Up screen, tap any field
6. Type long content
7. Tap outside

**Expected Results:**
- [ ] Keyboard appears when field tapped
- [ ] Keyboard doesn't cover important UI elements
- [ ] Tapping outside dismisses keyboard
- [ ] Can still see action buttons when keyboard is up
- [ ] Scrolling works if needed

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 3.3: Touch Targets
**Objective:** Verify all buttons are easy to tap

**Steps:**
1. Try tapping all buttons with your finger (or cursor)
2. Assess ease of tapping

**Buttons to test:**
- [ ] Login button - easy to tap?
- [ ] Sign Up link - easy to tap?
- [ ] Password visibility eye icon - easy to tap?
- [ ] New conversation + button - easy to tap?
- [ ] Profile button - easy to tap?
- [ ] Sign out in menu - easy to tap?

**Expected Results:**
- [ ] All buttons ≥44x44 points (iOS minimum)
- [ ] No accidental taps on wrong elements
- [ ] Visual feedback on tap (color change, etc.)

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

## 📋 Test Suite 4: Error Handling

### Test 4.1: Invalid Login Credentials
**Objective:** Verify error handling for wrong password

**Steps:**
1. On Login screen, enter:
   - Email: `test@messengerai.com`
   - Password: `wrongpassword`
2. Tap Login
3. Observe result

**Expected Results:**
- [ ] Loading spinner appears briefly
- [ ] Error alert appears
- [ ] Error message is user-friendly (not technical)
- [ ] Can tap "OK" to dismiss
- [ ] Back on login screen, can try again
- [ ] No crash

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 4.2: Sign Up with Existing Email
**Objective:** Verify duplicate email handling

**Steps:**
1. Navigate to Sign Up screen
2. Enter:
   - Display Name: `Another User`
   - Email: `test@messengerai.com` (already exists!)
   - Password: `password123`
   - Confirm Password: `password123`
3. Tap "Create Account"
4. Observe result

**Expected Results:**
- [ ] Loading spinner appears
- [ ] Error alert appears
- [ ] Error says email is already in use
- [ ] User-friendly message
- [ ] Can dismiss and try different email

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

## 📋 Test Suite 5: Data Persistence (Firestore)

### Test 5.1: User Data in Firestore
**Objective:** Verify user data is saved correctly

**Steps:**
1. Login as test@messengerai.com
2. Open http://localhost:4000
3. Click "Firestore" tab
4. Click "users" collection
5. Click on user document
6. Examine data

**Expected Results:**
- [ ] User document exists with correct ID
- [ ] Fields present:
  - [ ] id (matches auth UID)
  - [ ] displayName ("Test User")
  - [ ] email (test@messengerai.com)
  - [ ] isOnline (should be true after login)
  - [ ] lastSeen (recent timestamp)
  - [ ] createdAt (timestamp)

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

### Test 5.2: Online Status Updates
**Objective:** Verify isOnline updates on login/logout

**Steps:**
1. While logged in, check Firestore user document
2. Note `isOnline` value (should be true)
3. Sign out
4. Refresh Firestore
5. Check `isOnline` value again

**Expected Results:**
- [ ] When logged in: isOnline = true
- [ ] When signed out: isOnline = false
- [ ] lastSeen timestamp updates

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

## 📋 Test Suite 6: Navigation & UI Flow

### Test 6.1: Complete User Journey
**Objective:** Test entire flow from start to finish

**Steps:**
1. App launches → Login screen
2. Tap Sign Up
3. Create account: user3@messengerai.com / password123
4. Should auto-login and go to Messages
5. Tap profile button
6. Verify user info correct
7. Sign out
8. Login again with same credentials
9. Should see Messages screen

**Expected Results:**
- [ ] Smooth flow, no crashes
- [ ] All transitions work
- [ ] Data persists between login/logout
- [ ] Can login multiple times
- [ ] UI always responds appropriately

**Pass/Fail:** ☐ Pass ☐ Fail  
**Notes:**

---

## 📋 Test Suite 7: Visual Design Quality

### Test 7.1: Overall Visual Assessment
**Objective:** Assess professional appearance

**Checklist:**
- [ ] All text is legible (good contrast, appropriate sizes)
- [ ] Spacing is consistent throughout
- [ ] Colors follow iOS design guidelines
- [ ] Icons are clear and appropriate
- [ ] Buttons look tappable
- [ ] Forms are well-organized
- [ ] No text cutoff or overflow
- [ ] Animations are smooth
- [ ] Loading states are clear
- [ ] Error messages are friendly

**Overall Rating:** ☐ Excellent ☐ Good ☐ Needs Work

**Notes:**

---

## 🐛 Issues Found

Document any issues encountered:

### Issue #1
**Screen:**  
**Description:**  
**Steps to Reproduce:**  
**Expected:**  
**Actual:**  
**Severity:** ☐ Critical ☐ Major ☐ Minor

### Issue #2
**Screen:**  
**Description:**  
**Steps to Reproduce:**  
**Expected:**  
**Actual:**  
**Severity:** ☐ Critical ☐ Major ☐ Minor

---

## ✅ Test Summary

**Total Tests:** 15  
**Tests Passed:** ___  
**Tests Failed:** ___  
**Issues Found:** ___

**Overall Result:** ☐ Pass ☐ Pass with Issues ☐ Fail

**Tester Signature:** _____________  
**Date:** _____________

---

## 📝 Additional Notes

[Space for any additional observations, suggestions, or comments]

---

**All tests complete? PRs #2-7 are production-ready!** 🎉

