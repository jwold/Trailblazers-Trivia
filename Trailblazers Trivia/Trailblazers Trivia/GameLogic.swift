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

struct AnsweredQuestion {
    let player: Player
    let question: Question
    let wasCorrect: Bool
    let timestamp: Date
}

@Observable
class GameViewModel {
    private let player1: Player
    private let player2: Player
    private var currentPlayerIndex = 0
    
    var answeredQuestions: [AnsweredQuestion] = []
    var showAnswer = false
    var gameEnded = false
    var currentQuestion: Question
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
    
    // Computed property for scores
    var player1Score: Int {
        answeredQuestions
            .filter { $0.player.id == player1.id && $0.wasCorrect }
            .reduce(0) { total, answered in
                total + (answered.question.difficulty == .hard ? 3 : 1)
            }
    }
    
    var player2Score: Int {
        answeredQuestions
            .filter { $0.player.id == player2.id && $0.wasCorrect }
            .reduce(0) { total, answered in
                total + (answered.question.difficulty == .hard ? 3 : 1)
            }
    }
    
    var currentPlayerScore: Int {
        currentPlayerIndex == 0 ? player1Score : player2Score
    }
    
    init(player1Name: String = "Player 1", player2Name: String = "Player 2") {
        self.player1 = Player(id: UUID().uuidString, name: player1Name)
        self.player2 = Player(id: UUID().uuidString, name: player2Name)
        self.currentQuestion = easyQuestions[0] // Start with first easy question
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
    
    func setNextQuestion(difficulty: Difficulty) {
        if difficulty == .easy {
            if let nextQuestion = getNextEasyQuestion() {
                currentQuestion = nextQuestion
            }
        } else {
            if let nextQuestion = getNextHardQuestion() {
                currentQuestion = nextQuestion
            }
        }
    }
    
    func setNextQuestion() {
        setNextQuestion(difficulty: selectedDifficulty)
    }
    
    func changeDifficulty(to newDifficulty: Difficulty) {
        selectedDifficulty = newDifficulty
        resetGame()
        setNextQuestion()
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
        let answeredQuestion = AnsweredQuestion(
            player: currentPlayer,
            question: currentQuestion,
            wasCorrect: wasCorrect,
            timestamp: Date()
        )
        answeredQuestions.append(answeredQuestion)
        showAnswer = false
    }
    
    private func nextTurn() {
        // Switch to next player
        currentPlayerIndex = (currentPlayerIndex + 1) % 2
        
        // Check if game should end (example: 10 total questions)
        if answeredQuestions.count >= 10 {
            gameEnded = true
        }
    }
    
    func resetGame() {
        answeredQuestions.removeAll()
        usedEasyQuestions.removeAll()
        usedHardQuestions.removeAll()
        currentPlayerIndex = 0
        showAnswer = false
        gameEnded = false
        currentQuestion = easyQuestions[0]
    }
    
    func showAnswerToggle() {
        showAnswer.toggle()
    }
}

