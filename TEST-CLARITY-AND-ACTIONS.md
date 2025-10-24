# Test Guide - Clarity Assistant & Action Items
**PRs #20-21 Feature Testing**  
**Time:** 10-15 minutes

---

## 🎯 New Features to Test

**PR #20 - Clarity Assistant:**
- AI checks your message before you send it
- Suggests improvements for clarity
- Warns about tone issues
- Shows alternative phrasing

**PR #21 - Action Items:**
- Auto-extracts tasks from conversations
- Track who needs to do what
- Mark items complete
- Filter by status

---

## 🧪 TEST 1: Clarity Assistant (5 min)

### How to Access:
**Clarity checking happens automatically while typing!**

### Test 1.1: Type an Unclear Message

**In any chat, start typing:**
1. Type: "can u do the thing tmrw?"
2. **Wait 2 seconds** (debounced)
3. Look for clarity suggestion to appear

**Expected:**
- Clarity suggestion view appears
- Shows issues: "Unclear reference", "Informal language"
- Suggests: "Can you complete [task] by tomorrow?"
- Options: Accept | Dismiss | More

**✅ Pass if:**
- Suggestion appears after typing
- Issues clearly explained
- Can accept or dismiss
- Accepting replaces your text

---

### Test 1.2: Type a Clear Message

**Type a clear message:**
1. Type: "I will complete the report by Friday at 5pm"
2. Wait 2 seconds

**Expected:**
- NO suggestion appears
- Message is clear, no issues
- Can send directly

**✅ Pass if:**
- No unnecessary suggestions
- Clear messages pass through

---

### Test 1.3: Test Tone Warning

**Type something with wrong tone:**
1. Type: "This is totally wrong and you messed up!"
2. Wait 2 seconds

**Expected:**
- Suggestion appears
- Tone warning: "Message may sound aggressive"
- Suggests softer alternative
- Can accept or dismiss

**✅ Pass if:**
- Tone issues detected
- Helpful suggestions provided

---

## 🧪 TEST 2: Action Items (5 min)

### How to Access:
**Action items extracted from conversation automatically**

### Test 2.1: Find Action Items View

**From a conversation:**
1. Look for action items button (should be in toolbar)
2. Or check conversation list for action item indicators

**Expected:**
- Access point to ActionItemsView
- Can see list of extracted items

---

### Test 2.2: View Action Items

**Open ActionItemsView:**

**Expected to see:**
- Filter tabs: All | Open | Completed
- List of action items extracted from messages
- Each item shows:
  - Description
  - Assignee (if mentioned)
  - Due date (if mentioned)
  - Checkbox to mark complete

**✅ Pass if:**
- Items displayed clearly
- Can switch between filters
- UI is clean and organized

---

### Test 2.3: Mark Item Complete

**Tap checkbox on an action item:**

**Expected:**
- Checkmark appears
- Item marked complete
- Moves to "Completed" tab
- Visual indication (strikethrough or grey)

**✅ Pass if:**
- Completion toggles work
- Filters update correctly
- State persists

---

### Test 2.4: Swipe to Delete Action Item

**Swipe left on an action item:**

**Expected:**
- Red delete button appears
- Tap to delete
- Item removed from list

**✅ Pass if:**
- Swipe gesture works
- Deletion works
- No crash

---

## 🧪 TEST 3: Integration (5 min)

### Test 3.1: All Features Together

**In a conversation:**
1. Try typing (clarity check)
2. Tap summarize (AI summary)
3. View action items
4. Send messages (real-time)

**✅ Pass if:**
- All features work together
- No conflicts
- No crashes
- Smooth experience

---

### Test 3.2: Create Action Item from Conversation

**Have this conversation:**

**Alice:** "Can you review the PR by Friday?"

**Bob:** "Yes, I'll review it by Friday 3pm"

**Then:**
1. Extract action items (if auto-extract enabled)
2. Or manually trigger extraction

**Expected:**
- Action item appears: "Review PR by Friday 3pm"
- Assigned to: Bob
- Due: Friday

**✅ Pass if:**
- AI correctly extracts commitment
- Assignee identified
- Deadline captured

---

## 📊 TEST RESULTS

### Clarity Assistant:
- [ ] Suggestions appear: ☐ Pass ☐ Fail
- [ ] Issues identified correctly: ☐ Pass ☐ Fail
- [ ] Accept/Dismiss works: ☐ Pass ☐ Fail
- [ ] Debouncing works (2 sec delay): ☐ Pass ☐ Fail

### Action Items:
- [ ] View accessible: ☐ Pass ☐ Fail
- [ ] Items display correctly: ☐ Pass ☐ Fail
- [ ] Mark complete works: ☐ Pass ☐ Fail
- [ ] Filters work: ☐ Pass ☐ Fail
- [ ] Swipe-to-delete works: ☐ Pass ☐ Fail

### Integration:
- [ ] Features work together: ☐ Pass ☐ Fail
- [ ] No crashes: ☐ Pass ☐ Fail

---

## ⚠️ IMPORTANT NOTES

**Mock AI Responses:**
- Clarity and Action Items may return mock/empty responses
- This is OK for testing the UI/UX
- Cloud Functions need real OpenAI integration

**Expected Behavior:**
- Clarity: May not show suggestions (mock returns empty)
- Actions: May not find items (mock returns empty)
- Summarization: Works with real GPT-4!

**This tests the infrastructure, not the AI quality yet.**

---

## ✅ Success Criteria

**UI/UX works:** Features accessible, no crashes  
**Integration works:** All features coexist  
**Code quality:** Clean, professional

**AI Quality:** To be tested when functions fully integrated

---

**Start testing! Report any issues you find.** 🧪

