# Win Conditions by Game Mode
## TrailblazersTrivia - November 19, 2025

Understanding how each game mode determines when the game ends and who wins.

---

## 🎮 GAME CONSTANTS

All win conditions reference these constants defined in `GameConstants.swift`:

```swift
struct GameConstants {
    struct Game {
        static let winningScore: Double = 10.0
        static let maxQuestions = 20
    }
}
```

---

## 🏆 WIN CONDITIONS BY MODE

### **1. Group Mode (Shout Out Mode)** 
**File**: `GameScreen.swift` using `GameViewModel`

**Win Condition:**
```swift
var shouldEndGame: Bool {
    players.contains { getPlayerScore(for: $0) >= GameConstants.Game.winningScore }
}
```

**What This Means:**
- ✅ **Game ends when**: Any team reaches **10 points**
- ✅ **Winner determined by**: Team with highest score at game end
- ✅ **Tie handling**: If tied at 10 points, NO winner is declared (tie game)

**Gameplay:**
- Two teams alternate turns
- Questions continue until one team hits 10 points
- No maximum question limit
- First team to 10 wins immediately

**Example:**
```
Team One: 10 points  ← Reaches 10 first
Team Two: 7 points
Result: Team One WINS! 🏆
```

---

### **2. Couch Mode (2P Mode)**
**File**: `CouchModeGameScreen.swift` using `GameViewModel`

**Win Condition:**
```swift
var shouldEndGame: Bool {
    players.contains { getPlayerScore(for: $0) >= GameConstants.Game.winningScore }
}
```

**What This Means:**
- ✅ **Game ends when**: Any player reaches **10 points**
- ✅ **Winner determined by**: Player with highest score at game end
- ✅ **Tie handling**: If tied at 10 points, NO winner is declared (tie game)

**Gameplay:**
- Two players alternate turns
- Each player selects their answer from multiple choice
- Questions continue until one player hits 10 points
- No maximum question limit
- First player to 10 wins immediately

**Example:**
```
Player 1 (Alice): 10 points  ← Reaches 10 first
Player 2 (Bob):   8 points
Result: Alice WINS! 🏆
```

---

### **3. Single Player Mode (1P Mode)**
**File**: `SinglePlayerGameScreen.swift` using `SinglePlayerGameViewModel`

**Win Condition:**
```swift
var shouldEndGame: Bool {
    getPlayerScore() >= GameConstants.Game.winningScore || 
    turns.count >= GameConstants.Game.maxQuestions
}
```

**What This Means:**
- ✅ **Game ends when**: EITHER condition is met:
  1. Player reaches **10 points** (success!)
  2. Player answers **20 questions** (time's up!)
- ✅ **Winner**: Player is always marked as "winner" (solo game)
- ✅ **Success measured by**: Final score out of 10

**Gameplay:**
- Solo player answers questions
- Each question has 4 multiple choice options
- Game continues until 10 correct OR 20 total questions
- Timer tracks elapsed time
- No direct "win/loss" but score indicates performance

**Examples:**

**Scenario 1 - Early Success:**
```
Score: 10 points
Questions answered: 12
Result: SUCCESS! You reached 10 points! ✅
```

**Scenario 2 - Time's Up:**
```
Score: 7 points
Questions answered: 20
Result: Good effort! You scored 7/10 ⏱️
```

**Scenario 3 - Perfect Score:**
```
Score: 10 points
Questions answered: 10
Result: PERFECT! 10 correct in a row! 🔥
```

---

## 📊 COMPARISON TABLE

| Feature | Group Mode | Couch Mode | Single Player |
|---------|-----------|-----------|--------------|
| **Players** | 2 teams | 2 players | 1 player |
| **Win Score** | 10 points | 10 points | 10 points |
| **Max Questions** | ∞ (Unlimited) | ∞ (Unlimited) | 20 questions |
| **Ends When** | First to 10 | First to 10 | 10 points OR 20 questions |
| **Turn System** | Alternating | Alternating | Solo continuous |
| **Answer Format** | Reader reveals | Multiple choice | Multiple choice |
| **Time Tracking** | ❌ No | ❌ No | ✅ Yes |
| **Tie Possible** | ✅ Yes | ✅ Yes | ❌ N/A (solo) |

---

## 🎯 WINNER DETERMINATION LOGIC

### **Group & Couch Modes:**

```swift
func getAllPlayerScores() -> [PlayerScore] {
    // Get all scores
    var playerScores = players.map { ... }
    
    // Find players who reached 10 points
    let playersWithWinningScore = playerScores.filter { 
        $0.score >= GameConstants.Game.winningScore 
    }
    
    // Find the highest score among winners
    let maxScore = playersWithWinningScore.map { $0.score }.max() ?? 0
    let winners = playersWithWinningScore.filter { $0.score == maxScore }
    
    // Only mark as winner if there's ONE clear winner (no tie)
    if winners.count == 1, let winnerName = winners.first?.name {
        // Mark winner
    }
    
    return playerScores
}
```

**Key Points:**
- Must reach 10 points to be eligible to win
- Must have highest score among eligible players
- Ties result in NO winner being declared

**Examples:**

```
Scenario 1 - Clear Winner:
Team One: 10 points  ← WINNER
Team Two: 8 points
Result: Team One marked as winner ✅

Scenario 2 - Tie Game:
Team One: 10 points
Team Two: 10 points
Result: NO winner declared (tie) 🤝

Scenario 3 - Both Over 10:
Team One: 12 points  ← WINNER (higher score)
Team Two: 10 points
Result: Team One marked as winner ✅

Scenario 4 - Neither at 10:
Team One: 9 points
Team Two: 8 points
Result: Game continues (shouldn't happen, but no winner)
```

---

### **Single Player Mode:**

```swift
func getAllPlayerScores() -> [PlayerScore] {
    let finalScore = getPlayerScore()
    return [PlayerScore(
        name: player.name,
        score: finalScore,
        isWinner: true // Always marked as winner
    )]
}
```

**Key Points:**
- Always marked as "winner" (solo game)
- True success measured by score and time
- Results screen shows performance metrics

---

## 🔄 GAME FLOW

### **Group/Couch Mode Flow:**

```
1. Game starts
2. Player/Team 1 gets question
3. Answer (correct/wrong)
4. Check: Did anyone reach 10 points?
   YES → Game ends, determine winner
   NO  → Switch to next player/team
5. Repeat from step 2
```

### **Single Player Flow:**

```
1. Game starts, timer begins
2. Player gets question
3. Select from 4 multiple choice options
4. Check: Did player reach 10 points OR answer 20 questions?
   YES → Game ends, show results
   NO  → Next question
5. Repeat from step 2
```

---

## 🏅 RESULTS SCREEN BEHAVIOR

### **Group/Couch Mode Results:**

Shows both players/teams with:
- Final scores
- "WINNER" badge (if applicable)
- "Play Again" button

**Example:**
```
Final Scores
━━━━━━━━━━━━
Team One    [WINNER]
10 points

Team Two
7 points
```

### **Single Player Results:**

Shows detailed performance:
- Final score (e.g., "7")
- Total questions answered
- Elapsed time
- Progress percentage
- Stats breakdown (correct/wrong)

**Example:**
```
Great Job!
You answered 15 questions in 3:24

Final Score
7
out of 10 points

Progress: 70%

Stats:
15 Questions | 7 Correct | 8 Wrong | 3:24 Time
```

---

## ⚙️ MODIFYING WIN CONDITIONS

To change the win conditions, edit `GameConstants.swift`:

```swift
struct GameConstants {
    struct Game {
        // Change winning score (default: 10)
        static let winningScore: Double = 15.0  // Now need 15 to win
        
        // Change max questions for single player (default: 20)
        static let maxQuestions = 30  // Now 30 questions max
    }
}
```

**Impact:**
- ✅ Changes apply to ALL game modes automatically
- ✅ No code changes needed elsewhere
- ✅ Results screens adapt automatically

---

## 🎲 SCORING SYSTEM

### **How Points Are Earned:**

**All Modes:**
- ✅ Correct answer = +1 point
- ❌ Wrong answer = 0 points (no penalty)
- Score = Total number of correct answers

**No Bonuses For:**
- Speed of answer
- Difficulty of question
- Consecutive correct answers
- Comeback wins

**Simple Formula:**
```
Final Score = Count of Correct Answers
```

---

## 🤔 EDGE CASES

### **What if both teams reach 10 on the same turn?**
**Answer**: Game ends immediately when first team hits 10. The other team doesn't get another turn.

### **What if single player gets 10 correct before 20 questions?**
**Answer**: Game ends immediately at 10 correct. They "win" faster!

### **What if single player never reaches 10 points?**
**Answer**: Game ends at 20 questions regardless. Final score shows their performance.

### **Can Group/Couch mode go past 10 points?**
**Answer**: No. Game checks `shouldEndGame` after each turn and ends immediately when any player hits 10.

### **What happens if there's a tie at 10-10?**
**Answer**: Both teams shown in results, neither marked as winner. It's a tie game! 🤝

---

## 📝 SUMMARY

**Quick Reference:**

| Mode | Win Condition | Max Questions | Time Limit |
|------|--------------|---------------|------------|
| **Group** | First to 10 points | None | None |
| **Couch (2P)** | First to 10 points | None | None |
| **Single Player** | 10 points OR 20 questions | 20 | None (tracked) |

**Key Takeaway:**
- Group/Couch = Race to 10 points (unlimited questions)
- Single Player = Get 10 points within 20 questions (timed for stats)

All modes are designed to be completable in a reasonable time frame while maintaining competitive gameplay! 🎮

