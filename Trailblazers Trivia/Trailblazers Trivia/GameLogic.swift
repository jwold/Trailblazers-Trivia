//
//  GameLogic.swift
//  Trailblazers Trivia
//
//  Created by Tony Stark on 9/23/25.
//

import Foundation

@Observable
class GameViewModel {
    private let players: [Player]
    private let questionRepository: QuestionRepositoryProtocol
    private var currentPlayerIndex = 0
    
    var turns: [Turn] = []
    var currentTurn: Turn?
    var showAnswer = false
    var gameEnded = false
    var selectedDifficulty: Difficulty = .hard
    
    var currentPlayer: Player {
        players[currentPlayerIndex]
    }
    
    var player1: Player {
        players[0]
    }
    
    var player2: Player {
        players[1]
    }
    
    var currentQuestion: Question {
        currentTurn?.question ?? Question(id: "default", question: "Loading...", answer: "...", wrongAnswers: ["Loading...", "Loading..."], difficulty: .easy)
    }
    
    // Computed property for scores
    func getPlayerScore(for player: Player) -> Double {
        let playerTurns = turns.filter { $0.player.id == player.id }
        var score: Double = 0.0
        
        for turn in playerTurns {
            if turn.wasCorrect {
                score += 1.0 // +1 point for correct
            } else {
                score -= 0.5 // -0.5 points for wrong
            }
        }
        
        return max(0, score) // Can't go below 0
    }
    
    // Export all player scores for use in views
    func getAllPlayerScores() -> [PlayerScore] {
        // First, get all player scores with isWinner hardcoded to false
        var playerScores = players.map { player in
            PlayerScore(
                name: player.name,
                score: getPlayerScore(for: player),
                isWinner: false
            )
        }
        
        // Find players with winning score (>= 10 points)
        let playersWithWinningScore = playerScores.filter { $0.score >= 10 }
        
        guard !playersWithWinningScore.isEmpty else { return playerScores }
        
        // Find the maximum score among winning players
        let maxScore = playersWithWinningScore.map { $0.score }.max() ?? 0
        let winners = playersWithWinningScore.filter { $0.score == maxScore }
        
        // Only mark as winner if there's a clear winner (no tie)
        if winners.count == 1, let winnerName = winners.first?.name {
            // Update the playerScores array to mark the winner
            playerScores = playerScores.map { playerScore in
                PlayerScore(
                    name: playerScore.name,
                    score: playerScore.score,
                    isWinner: playerScore.name == winnerName
                )
            }
        }
        
        return playerScores
    }
    
    var currentPlayerScore: Double {
        getPlayerScore(for: currentPlayer)
    }
    
    var shouldEndGame: Bool {
        players.contains { getPlayerScore(for: $0) >= 10 }
    }
    
    init(
        player1Name: String = "Player 1", 
        player2Name: String = "Player 2",
        questionRepository: QuestionRepositoryProtocol? = nil
    ) {
        self.players = [
            Player(id: UUID().uuidString, name: player1Name),
            Player(id: UUID().uuidString, name: player2Name)
        ]
        self.questionRepository = questionRepository ?? QuestionRepositoryFactory.create(type: .json)
        
        Task {
            await startNewTurn()
        }
    }
    
    @MainActor
    func startNewTurn() async {
        // Create turn with player first
        currentTurn = Turn(player: currentPlayer)
        
        // Then load the question
        do {
            let question = try await questionRepository.nextQuestion(for: selectedDifficulty)
            currentTurn?.question = question
        } catch {
            print("Failed to get question: \(error)")
            // Fallback to a default question or handle error appropriately
        }
    }
    
    @MainActor
    func changeDifficultyForCurrentTurn(to newDifficulty: Difficulty) async {
        selectedDifficulty = newDifficulty
        // Only update the current turn if it hasn't been answered yet
        if let turn = currentTurn, !turn.isAnswered {
            do {
                let newQuestion = try await questionRepository.nextQuestion(for: newDifficulty)
                currentTurn?.question = newQuestion
            } catch {
                print("Failed to get question for difficulty change: \(error)")
            }
        }
    }
    
    func answeredCorrect() {
        recordAnswer(wasCorrect: true)
        Task {
            await nextTurn()
        }
    }
    
    func answeredWrong() {
        recordAnswer(wasCorrect: false)
        Task {
            await nextTurn()
        }
    }
    
    private func recordAnswer(wasCorrect: Bool) {
        guard var turn = currentTurn else { return }
        
        // Update the current turn with answer information
        turn.isAnswered = true
        turn.wasCorrect = wasCorrect
        
        // Add the completed turn to answered questions
        turns.append(turn)
        
        // Update current turn to reflect the answered state
        currentTurn = turn
        
        showAnswer = false
    }
    
    @MainActor
    private func nextTurn() async {
        // Check if game should end (when a player reaches 10 points)
        if shouldEndGame {
            gameEnded = true
            return
        }
        
        // Switch to next player
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        await startNewTurn()
    }
    
    func resetGame() {
        turns.removeAll()
        questionRepository.resetUsedQuestions()
        currentPlayerIndex = 0
        showAnswer = false
        gameEnded = false
        Task {
            await startNewTurn()
        }
    }
    
    func showAnswerToggle() {
        showAnswer.toggle()
    }
}

struct PlayerScore: Hashable {
    let name: String
    let score: Double
    let isWinner: Bool
}

struct Player {
    let id: String
    let name: String
}

enum Difficulty {
    case easy
    case hard
}

struct Question {
    let id: String
    let question: String
    let answer: String
    let wrongAnswers: [String]
    let difficulty: Difficulty
}

struct Turn {
    let player: Player
    var question: Question?
    var isAnswered: Bool = false
    var wasCorrect: Bool = false
    
    var difficulty: Difficulty? {
        question?.difficulty
    }
}

@Observable
class SinglePlayerGameViewModel {
    let player: Player
    private let questionRepository: QuestionRepositoryProtocol
    private var gameStartTime: Date?
    private var timer: Timer?
    
    var turns: [Turn] = []
    var currentTurn: Turn?
    var gameEnded = false
    var selectedDifficulty: Difficulty = .hard
    var hasAnswered = false
    var selectedAnswer: String?
    var currentAnswerOptions: [String] = []
    var elapsedTime: TimeInterval = 0
    
    var currentQuestion: Question {
        currentTurn?.question ?? Question(id: "default", question: "Loading...", answer: "...", wrongAnswers: ["Loading...", "Loading..."], difficulty: .easy)
    }
    
    // Computed property for score
    func getPlayerScore() -> Double {
        let playerTurns = turns.filter { $0.player.id == player.id }
        var score: Double = 0.0
        
        for turn in playerTurns {
            if turn.wasCorrect {
                score += 1.0 // +1 point for correct
            } else {
                score -= 0.5 // -0.5 points for wrong
            }
        }
        
        return max(0, score) // Can't go below 0
    }
    
    // Export player score for results screen
    func getAllPlayerScores() -> [PlayerScore] {
        let finalScore = getPlayerScore()
        return [PlayerScore(
            name: player.name,
            score: finalScore,
            isWinner: true // Single player is always the "winner"
        )]
    }
    
    var shouldEndGame: Bool {
        getPlayerScore() >= 10 || turns.count >= 20 // End after 10 points or 20 questions
    }
    
    init(
        playerName: String = "Player",
        questionRepository: QuestionRepositoryProtocol? = nil
    ) {
        self.player = Player(id: UUID().uuidString, name: playerName)
        self.questionRepository = questionRepository ?? QuestionRepositoryFactory.create(type: .json)
        
        startTimer()
        
        Task {
            await startNewTurn()
        }
    }
    
    @MainActor
    func startNewTurn() async {
        hasAnswered = false
        selectedAnswer = nil
        
        // Create turn with player first
        currentTurn = Turn(player: player)
        
        // Then load the question
        do {
            let question = try await questionRepository.nextQuestion(for: selectedDifficulty)
            currentTurn?.question = question
            generateAnswerOptions()
        } catch {
            print("Failed to get question: \(error)")
            // Fallback to a default question or handle error appropriately
        }
    }
    
    private func generateAnswerOptions() {
        guard let question = currentTurn?.question else { return }
        
        // Use the wrong answers from the question data
        let wrongAnswers = question.wrongAnswers
        
        // Combine correct answer with wrong answers and shuffle
        var options = wrongAnswers + [question.answer]
        options.shuffle()
        
        currentAnswerOptions = options
    }

    
    func selectAnswer(_ answer: String) {
        guard !hasAnswered else { return }
        
        hasAnswered = true
        selectedAnswer = answer
        
        let wasCorrect = answer == currentQuestion.answer
        recordAnswer(wasCorrect: wasCorrect)
        
        // Don't automatically progress - wait for Continue button
    }
    
    @MainActor
    func continueToNextQuestion() async {
        // Check if game should end
        if shouldEndGame {
            gameEnded = true
            return
        }
        
        await startNewTurn()
    }
    
    private func recordAnswer(wasCorrect: Bool) {
        guard var turn = currentTurn else { return }
        
        // Update the current turn with answer information
        turn.isAnswered = true
        turn.wasCorrect = wasCorrect
        
        // Add the completed turn to answered questions
        turns.append(turn)
        
        // Update current turn to reflect the answered state
        currentTurn = turn
    }
    
    @MainActor
    private func nextTurn() async {
        // Check if game should end
        if shouldEndGame {
            stopTimer()
            gameEnded = true
            return
        }
        
        await startNewTurn()
    }
    
    private func startTimer() {
        gameStartTime = Date()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.gameStartTime else { return }
            DispatchQueue.main.async {
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Format elapsed time as MM:SS
    func formatElapsedTime() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func resetGame() {
        turns.removeAll()
        questionRepository.resetUsedQuestions()
        hasAnswered = false
        selectedAnswer = nil
        gameEnded = false
        stopTimer()
        startTimer()
        Task {
            await startNewTurn()
        }
    }
    
    deinit {
        stopTimer()
    }
}
