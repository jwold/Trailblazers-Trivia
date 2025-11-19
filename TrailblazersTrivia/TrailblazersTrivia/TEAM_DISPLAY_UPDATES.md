# Team Display Updates - Underlines & Player Names
## TrailblazersTrivia - November 19, 2025

Updated team/player display styling and naming across game modes.

---

## 🎨 STYLING CHANGES

### **1. Replaced Capsule Bubble with Blue Underline**

**Before:**
```
┌─────────────────────────┐
│  Team One: 3            │  ← Filled blue capsule
└─────────────────────────┘
```

**After:**
```
  Team One: 3
  ───────────  ← Blue underline only
```

**Implementation:**
- Removed: Capsule background with fill
- Added: 3pt tall Rectangle at bottom
- Changed: VStack layout instead of HStack
- Changed: All text is white (no color change for active player)
- Active player indicated by blue underline only

---

## 📝 NAMING CHANGES

### **Mode-Specific Names**

| Mode | Old Names | New Names | Reason |
|------|-----------|-----------|--------|
| **Group** | "Team One" / "Team Two" | "Team One" / "Team Two" | ✅ No change |
| **2P (Couch)** | "Team One" / "Team Two" | "Player 1" / "Player 2" | Different context |
| **1P (Single)** | "Player" | "Player" | ✅ No change |

---

## 🔧 TECHNICAL CHANGES

### **TriviaCategory.swift**

Added `isCouchMode` parameter to differentiate between modes:

```swift
// BEFORE
static func generateTeamNames(for category: TriviaCategory) -> (team1: String, team2: String) {
    return ("Team One", "Team Two")
}

// AFTER
static func generateTeamNames(for category: TriviaCategory, isCouchMode: Bool = false) -> (team1: String, team2: String) {
    if isCouchMode {
        return ("Player 1", "Player 2")
    }
    return ("Team One", "Team Two")
}
```

### **CouchModeGameScreen.swift**

**Changes:**
1. Updated init to pass `isCouchMode: true`
2. Changed layout from `HStack` to `VStack` for name/score stacking
3. Replaced Capsule with bottom Rectangle underline
4. Removed conditional text colors (always white now)
5. Underline appears for active player only

### **GameScreen.swift (Group Mode)**

**Changes:**
1. Changed layout from `HStack` to `VStack` for name/score stacking
2. Replaced Capsule with bottom Rectangle underline
3. Removed conditional text colors (always white now)
4. Underline appears for active player only

---

## 📊 VISUAL COMPARISON

### **Group Mode (GameScreen)**

**Before:**
```
╔════════════════════════════════════╗
║  ┌──────────────┐  ┌──────────────┐ ║
║  │ Team One: 3  │  │ Team Two: 5  │ ║ ← Black text on blue capsules
║  └──────────────┘  └──────────────┘ ║
╚════════════════════════════════════╝
```

**After:**
```
╔════════════════════════════════════╗
║   Team One        Team Two          ║ ← White text
║      3                5              ║
║   ────────                           ║ ← Blue underline (active)
╚════════════════════════════════════╝
```

### **2P Couch Mode (CouchModeGameScreen)**

**Before:**
```
╔════════════════════════════════════╗
║  ┌──────────────┐  ┌──────────────┐ ║
║  │ Team One: 3  │  │ Team Two: 5  │ ║
║  └──────────────┘  └──────────────┘ ║
╚════════════════════════════════════╝
```

**After:**
```
╔════════════════════════════════════╗
║   Player 1        Player 2          ║ ← Changed names
║      3                5              ║
║               ────────               ║ ← Blue underline (active)
╚════════════════════════════════════╝
```

---

## 💡 DESIGN RATIONALE

### **Why Underline Instead of Bubble?**

1. ✅ **Cleaner look** - Less visual clutter
2. ✅ **More elegant** - Subtle indicator vs bold capsule
3. ✅ **Better contrast** - White text on dark background easier to read
4. ✅ **Modern design** - Follows current UI trends
5. ✅ **Accessibility** - Better for color-blind users (shape + position)

### **Why "Player 1/2" for Couch Mode?**

1. ✅ **More personal** - Single device, individuals playing
2. ✅ **Clearer context** - "Teams" implies multiple people
3. ✅ **Matches UI pattern** - Similar to "Single Player" mode
4. ✅ **Less confusion** - "Team" might imply group of people

### **Why Keep "Team One/Two" for Group Mode?**

1. ✅ **Accurate context** - Multiple people per team
2. ✅ **Professional tone** - More formal for group settings
3. ✅ **Distinguishes mode** - Different name = different experience

---

## 🎯 COMPONENT STRUCTURE

### **New Underline Pattern**

```swift
VStack(spacing: 0) {
    // Name
    Text(playerName)
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundColor(GrayTheme.text)  // Always white
    
    // Score (TickerTape)
    TickerTapeScore(...)
}
.padding(.horizontal, 16)
.padding(.vertical, 12)
.background(
    VStack {
        Spacer()
        Rectangle()
            .fill(isActivePlayer ? GrayTheme.gold : Color.clear)
            .frame(height: 3)  // 3pt underline
    }
)
```

**Key Details:**
- VStack with Spacer pushes Rectangle to bottom
- Rectangle is 3pt tall (thin but visible)
- Color is gold/blue when active, clear when inactive
- Padding creates space around content

---

## 🧪 TESTING CHECKLIST

### **Group Mode (GameScreen)**
- [ ] Start Group mode
- [ ] Verify "Team One" and "Team Two" appear
- [ ] Verify active player has blue underline
- [ ] Verify inactive player has no underline
- [ ] Answer question and verify underline switches
- [ ] All text should be white

### **2P Couch Mode (CouchModeGameScreen)**
- [ ] Start Couch Mode
- [ ] Verify "Player 1" and "Player 2" appear
- [ ] Verify active player has blue underline
- [ ] Verify inactive player has no underline
- [ ] Answer question and verify underline switches
- [ ] All text should be white

### **Results Screen**
- [ ] Group mode → "Team One" / "Team Two" in results
- [ ] Couch mode → "Player 1" / "Player 2" in results

---

## 📋 TEAM NAME EDITING PLAN

*(For future implementation)*

**Recommended Approach: Edit on StartScreen**

When user selects Group or 2P mode, show editable text fields:

```swift
// Example UI
VStack {
    // Mode selector
    HStack {
        [1P] [2P✓] [Group]
    }
    
    // Editable names (appears when mode selected)
    VStack(alignment: .leading) {
        Text("Player Names")
            .font(.caption)
        
        TextField("Player 1", text: $player1Name)
        TextField("Player 2", text: $player2Name)
    }
    
    Button("Start Game") { ... }
}
```

**Implementation Steps:**
1. Add `@State var player1Name: String = "Player 1"`
2. Add `@State var player2Name: String = "Player 2"`
3. Show TextField when mode selected
4. Pass names to game screens on start
5. Optional: Save to UserDefaults for persistence

**Would you like me to implement this feature?**

---

## ✨ SUMMARY

**Changes Made:**
- ✅ Capsule bubble → Blue underline (Group + Couch modes)
- ✅ "Team One/Two" → "Player 1/2" (Couch mode only)
- ✅ Black/dimmed text → White text (all modes)
- ✅ Mode-aware name generation

**Result:**
- Cleaner, more modern UI
- Better visual hierarchy
- Mode-appropriate naming
- Improved accessibility

The team/player indicator is now subtle and elegant! 🎨

