# Team/Player Name Editing - Complete Implementation
## TrailblazersTrivia - November 19, 2025

Implemented in-game name editing with persistent storage across sessions.

---

## ✨ FEATURES IMPLEMENTED

### **1. Tap to Edit Names**
- Tap on any team/player name during the game
- Modal sheet appears with text field
- Changes apply immediately to current game
- Names persist across app launches

### **2. Persistent Storage**
- Custom names saved to UserDefaults
- Separate storage for Group mode vs Couch mode
- Names load automatically on next game start
- Can be reset to defaults if needed

### **3. Mode-Specific Names**
| Mode | Default Names | Storage Keys |
|------|---------------|--------------|
| **Group** | "Team One" / "Team Two" | `customGroupTeam1Name` / `customGroupTeam2Name` |
| **Couch (2P)** | "Player 1" / "Player 2" | `customCouchPlayer1Name` / `customCouchPlayer2Name` |

---

## 🔧 FILES MODIFIED

### **1. TeamNameStorage.swift** (NEW)
Manages persistent storage of custom names using UserDefaults.

**Key Features:**
```swift
// Get/Set Group mode team names
TeamNameStorage.groupTeam1Name = "Warriors"
TeamNameStorage.groupTeam2Name = "Champions"

// Get/Set Couch mode player names
TeamNameStorage.couchPlayer1Name = "Alice"
TeamNameStorage.couchPlayer2Name = "Bob"

// Reset to defaults
TeamNameStorage.resetGroupNames()
TeamNameStorage.resetCouchNames()
TeamNameStorage.resetAllNames()
```

---

### **2. TriviaCategory.swift**
Updated `TeamNameGenerator` to load names from storage.

**Before:**
```swift
static func generateTeamNames(...) -> (String, String) {
    if isCouchMode {
        return ("Player 1", "Player 2")
    }
    return ("Team One", "Team Two")
}
```

**After:**
```swift
static func generateTeamNames(...) -> (String, String) {
    if isCouchMode {
        return (TeamNameStorage.couchPlayer1Name, 
                TeamNameStorage.couchPlayer2Name)
    }
    return (TeamNameStorage.groupTeam1Name,
            TeamNameStorage.groupTeam2Name)
}
```

---

### **3. GameLogic.swift**
Added methods to update player names dynamically.

**Changes:**
- Changed `private let players` to `private var players` (mutable)
- Added `updatePlayer1Name(_ newName: String)`
- Added `updatePlayer2Name(_ newName: String)`

**Implementation:**
```swift
func updatePlayer1Name(_ newName: String) {
    guard !newName.isEmpty else { return }
    players[0] = Player(id: players[0].id, name: newName)
}
```

---

### **4. CouchModeGameScreen.swift**
Added editing UI and persistence for Couch Mode (2P).

**New State Variables:**
```swift
@State private var showEditPlayer1 = false
@State private var showEditPlayer2 = false
@State private var editingPlayer1Name = ""
@State private var editingPlayer2Name = ""
```

**Tap Gestures:**
```swift
.onTapGesture {
    editingPlayer1Name = gameViewModel.player1.name
    showEditPlayer1 = true
}
```

**Modal Sheets:**
```swift
.sheet(isPresented: $showEditPlayer1) {
    EditPlayerNameSheet(
        playerNumber: 1,
        currentName: $editingPlayer1Name,
        onSave: {
            TeamNameStorage.couchPlayer1Name = editingPlayer1Name
            gameViewModel.updatePlayer1Name(editingPlayer1Name)
        }
    )
}
```

**New Component:** `EditPlayerNameSheet`
- Clean modal interface
- Auto-focused text field
- Cancel/Save buttons
- Validates non-empty names

---

### **5. GameScreen.swift**
Added editing UI and persistence for Group Mode.

**New State Variables:**
```swift
@State private var showEditTeam1 = false
@State private var showEditTeam2 = false
@State private var editingTeam1Name = ""
@State private var editingTeam2Name = ""
```

**Tap Gestures & Sheets:** (Same pattern as CouchModeGameScreen)

**New Component:** `EditTeamNameSheet`
- Similar to EditPlayerNameSheet
- Different title text ("Team One" vs "Player 1")

---

## 🎯 USER FLOW

### **Editing a Name:**

1. **User taps on team/player name** during game
2. **Modal sheet appears** with text field
3. **Keyboard auto-focuses** for quick editing
4. **User types new name** (e.g., "Warriors")
5. **User taps "Save"** or presses Done on keyboard
6. **Name updates immediately** in game UI
7. **Name persists** to UserDefaults
8. **Sheet dismisses**

### **Persistence Flow:**

1. **First time launching app:**
   - Loads default names ("Team One", "Team Two", etc.)
   
2. **After editing names:**
   - Custom names saved to UserDefaults
   
3. **Next time launching app:**
   - Loads custom names from UserDefaults
   - Uses custom names for all new games
   
4. **Resetting names** (if feature added):
   - Call `TeamNameStorage.resetAllNames()`
   - Reverts to default names

---

## 💾 STORAGE STRUCTURE

### **UserDefaults Keys:**
```
customGroupTeam1Name     → "Team One" (default)
customGroupTeam2Name     → "Team Two" (default)
customCouchPlayer1Name   → "Player 1" (default)
customCouchPlayer2Name   → "Player 2" (default)
```

### **Storage Location:**
- Stored in app's UserDefaults domain
- Persists across app launches
- Survives app updates
- Deleted if app is uninstalled

---

## 🎨 UI COMPONENTS

### **EditPlayerNameSheet** (Couch Mode)
```
┌────────────────────────────────┐
│ Cancel         Edit Player     Save │
├────────────────────────────────┤
│                                │
│  Edit Player 1 Name            │
│                                │
│  ┌──────────────────────────┐ │
│  │ Alice                 █  │ │ ← Text field
│  └──────────────────────────┘ │
│                                │
└────────────────────────────────┘
```

### **EditTeamNameSheet** (Group Mode)
```
┌────────────────────────────────┐
│ Cancel      Edit Team One    Save │
├────────────────────────────────┤
│                                │
│  Edit Team One Name            │
│                                │
│  ┌──────────────────────────┐ │
│  │ Warriors              █  │ │ ← Text field
│  └──────────────────────────┘ │
│                                │
└────────────────────────────────┘
```

---

## 🧪 TESTING CHECKLIST

### **Couch Mode (2P)**
- [ ] Start Couch mode - see "Player 1" and "Player 2"
- [ ] Tap "Player 1" - edit sheet appears
- [ ] Change name to "Alice" - saves and updates
- [ ] Tap "Player 2" - edit sheet appears
- [ ] Change name to "Bob" - saves and updates
- [ ] Play game - both names show correctly
- [ ] Close app and reopen
- [ ] Start new Couch game - "Alice" and "Bob" appear
- [ ] Tap Cancel in edit sheet - no changes applied

### **Group Mode**
- [ ] Start Group mode - see "Team One" and "Team Two"
- [ ] Tap "Team One" - edit sheet appears
- [ ] Change name to "Warriors" - saves and updates
- [ ] Tap "Team Two" - edit sheet appears
- [ ] Change name to "Champions" - saves and updates
- [ ] Play game - both names show correctly
- [ ] Close app and reopen
- [ ] Start new Group game - "Warriors" and "Champions" appear

### **Edge Cases**
- [ ] Try to save empty name - Save button disabled
- [ ] Try to save whitespace-only name - Gets trimmed, save disabled
- [ ] Edit name mid-game - updates correctly
- [ ] Edit name, tap Cancel - reverts to original
- [ ] Keyboard Done button - saves and dismisses
- [ ] Very long names - truncates with ...

---

## 🚀 FUTURE ENHANCEMENTS

### **Potential Additions:**

1. **Reset Button in Settings**
   ```swift
   Button("Reset All Names") {
       TeamNameStorage.resetAllNames()
   }
   ```

2. **Name History/Presets**
   - Save frequently used names
   - Quick-select from dropdown

3. **Character Limit**
   - Enforce max 20 characters
   - Prevent layout breaking

4. **Name Validation**
   - Prevent profanity
   - Require unique names (Player 1 ≠ Player 2)

5. **Visual Indicator**
   - Small edit icon next to names
   - Hint that names are tappable

---

## 📊 BEFORE & AFTER

### **Before:**
- ❌ Fixed names: "Team One", "Team Two", "Player 1", "Player 2"
- ❌ No way to customize
- ❌ Same names for everyone

### **After:**
- ✅ Tap any name to edit
- ✅ Custom names persist
- ✅ Personalized experience
- ✅ Separate names per mode
- ✅ Works mid-game

---

## 🎯 SUMMARY

**What Changed:**
- ✅ Created TeamNameStorage for persistence
- ✅ Updated TeamNameGenerator to use stored names
- ✅ Made GameViewModel.players mutable
- ✅ Added update methods to GameViewModel
- ✅ Added tap gestures to name displays
- ✅ Created edit modal sheets
- ✅ Integrated with UserDefaults
- ✅ Applied to both Group and Couch modes

**Result:**
Users can now personalize their team/player names with a simple tap, and those names will be remembered for all future games! 🎉

**Example Use Cases:**
- Family game night: "Team Mom" vs "Team Dad"
- Friends playing: "Alice" vs "Bob"
- Youth group: "Warriors" vs "Champions"
- Classroom: Custom team names for students

The feature is intuitive, persistent, and enhances the personal connection to the game! 💯

