//
//  GameLogic.swift
//  Trailblazers Trivia
//
//  Created by Tony Stark on 9/23/25.
//

import Foundation

struct Player {
    let id: String
    let name: String
}

enum Difficulty {
    case easy
    case hard
}

struct Question {
    let question: String
    let answer: String
    let difficulty: Difficulty
}

struct Turn {
    let player: Player
    let difficulty: Difficulty
    let question: Question
    var isAnswered: Bool = false
    var wasCorrect: Bool = false
    let timestamp: Date
}

@Observable
class GameViewModel {
    private let player1: Player
    private let player2: Player
    private var currentPlayerIndex = 0
    
    var answeredQuestions: [Turn] = []
    var currentTurn: Turn?
    var showAnswer = false
    var gameEnded = false
    var selectedDifficulty: Difficulty = .hard
    
    // Easy questions pool
    private let easyQuestions = [
        Question(question: "How many close disciples did Jesus have?", answer: "12", difficulty: .easy),
        Question(question: "In what city was Jesus born?", answer: "Bethlehem", difficulty: .easy),
        Question(question: "How many days did it rain during the flood?", answer: "40 days", difficulty: .easy),
        Question(question: "Who led the Israelites out of Egypt?", answer: "Moses", difficulty: .easy),
        Question(question: "What did God create on the first day?", answer: "Light", difficulty: .easy),
        Question(question: "How many books are in the New Testament?", answer: "27", difficulty: .easy),
        Question(question: "Who was the first man?", answer: "Adam", difficulty: .easy),
        Question(question: "What was the first miracle of Jesus?", answer: "Turning water into wine", difficulty: .easy)
    ]
    
    // Hard questions pool
    private let hardQuestions = [
        Question(question: "Who was the first king of Israel?", answer: "Saul", difficulty: .hard),
        Question(question: "What is the shortest book in the New Testament?", answer: "2 John", difficulty: .hard),
        Question(question: "Who was the oldest man in the Bible?", answer: "Methuselah", difficulty: .hard),
        Question(question: "In what city did Paul meet Priscilla and Aquila?", answer: "Corinth", difficulty: .hard),
        Question(question: "What was the name of Abraham's nephew?", answer: "Lot", difficulty: .hard),
        Question(question: "How many sons did Jacob have?", answer: "12", difficulty: .hard),
        Question(question: "What was the name of the garden where Jesus prayed before his crucifixion?", answer: "Gethsemane", difficulty: .hard),
        Question(question: "Who was the mother of John the Baptist?", answer: "Elizabeth", difficulty: .hard)
    ]
    
    private var usedEasyQuestions: Set<Int> = []
    private var usedHardQuestions: Set<Int> = []
    
    var currentPlayer: Player {
        currentPlayerIndex == 0 ? player1 : player2
    }
    
    var firstPlayer: Player { player1 }
    var secondPlayer: Player { player2 }
    
    var currentQuestion: Question {
        currentTurn?.question ?? easyQuestions[0]
    }
    
    // Computed property for scores
    var player1Score: Int {
        answeredQuestions
            .filter { $0.player.id == player1.id && $0.wasCorrect }
            .reduce(0) { total, turn in
                total + (turn.question.difficulty == .hard ? 3 : 1)
            }
    }
    
    var player2Score: Int {
        answeredQuestions
            .filter { $0.player.id == player2.id && $0.wasCorrect }
            .reduce(0) { total, turn in
                total + (turn.question.difficulty == .hard ? 3 : 1)
            }
    }
    
    var currentPlayerScore: Int {
        currentPlayerIndex == 0 ? player1Score : player2Score
    }
    
    var gameWinner: String? {
        if player1Score >= 10 && player2Score >= 10 {
            return player1Score > player2Score ? player1.name : (player2Score > player1Score ? player2.name : nil)
        } else if player1Score >= 10 {
            return player1.name
        } else if player2Score >= 10 {
            return player2.name
        }
        return nil
    }
    
    var shouldEndGame: Bool {
        player1Score >= 10 || player2Score >= 10
    }
    
    init(player1Name: String = "Player 1", player2Name: String = "Player 2") {
        self.player1 = Player(id: UUID().uuidString, name: player1Name)
        self.player2 = Player(id: UUID().uuidString, name: player2Name)
        startNewTurn()
    }
    
    func getNextEasyQuestion() -> Question? {
        let availableIndices = Set(0..<easyQuestions.count).subtracting(usedEasyQuestions)
        
        guard let randomIndex = availableIndices.randomElement() else {
            // Reset if all questions used
            usedEasyQuestions.removeAll()
            return easyQuestions.randomElement()
        }
        
        usedEasyQuestions.insert(randomIndex)
        return easyQuestions[randomIndex]
    }
    
    func getNextHardQuestion() -> Question? {
        let availableIndices = Set(0..<hardQuestions.count).subtracting(usedHardQuestions)
        
        guard let randomIndex = availableIndices.randomElement() else {
            // Reset if all questions used
            usedHardQuestions.removeAll()
            return hardQuestions.randomElement()
        }
        
        usedHardQuestions.insert(randomIndex)
        return hardQuestions[randomIndex]
    }
    
    func startNewTurn() {
        let question = getQuestion(for: selectedDifficulty)
        currentTurn = Turn(
            player: currentPlayer,
            difficulty: selectedDifficulty,
            question: question,
            timestamp: Date()
        )
    }
    
    func changeDifficultyForCurrentTurn(to newDifficulty: Difficulty) {
        selectedDifficulty = newDifficulty
        // Only update the current turn if it hasn't been answered yet
        if let turn = currentTurn, !turn.isAnswered {
            let newQuestion = getQuestion(for: newDifficulty)
            currentTurn = Turn(
                player: turn.player,
                difficulty: newDifficulty,
                question: newQuestion,
                timestamp: turn.timestamp
            )
        }
    }
    
    private func getQuestion(for difficulty: Difficulty) -> Question {
        if difficulty == .easy {
            return getNextEasyQuestion() ?? easyQuestions[0]
        } else {
            return getNextHardQuestion() ?? hardQuestions[0]
        }
    }
    
    func answerCorrect() {
        recordAnswer(wasCorrect: true)
        nextTurn()
    }
    
    func answerWrong() {
        recordAnswer(wasCorrect: false)
        nextTurn()
    }
    
    private func recordAnswer(wasCorrect: Bool) {
        guard var turn = currentTurn else { return }
        
        // Update the current turn with answer information
        turn.isAnswered = true
        turn.wasCorrect = wasCorrect
        
        // Add the completed turn to answered questions
        answeredQuestions.append(turn)
        
        // Update current turn to reflect the answered state
        currentTurn = turn
        
        showAnswer = false
    }
    
    private func nextTurn() {
        // Check if game should end (when a player reaches 10 points)
        if shouldEndGame {
            gameEnded = true
            return
        }
        
        // Switch to next player
        currentPlayerIndex = (currentPlayerIndex + 1) % 2
        startNewTurn()
    }
    
    func resetGame() {
        answeredQuestions.removeAll()
        usedEasyQuestions.removeAll()
        usedHardQuestions.removeAll()
        currentPlayerIndex = 0
        showAnswer = false
        gameEnded = false
        startNewTurn()
    }
    
    func showAnswerToggle() {
        showAnswer.toggle()
    }
}

