//
//  GameLogic.swift
//  TrailblazersTrivia
//
//  Created by Tony Stark on 9/23/25.
//

import Foundation

@Observable
class GameViewModel {
    private var players: [Player]
    private let questionRepository: QuestionRepositoryProtocol
    private let category: TriviaCategory
    private var currentPlayerIndex = 0
    
    var turns: [Turn] = []
    var currentTurn: Turn?
    var showAnswer = false
    var gameEnded = false
    
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
        currentTurn?.question ?? Question(id: "default", question: "", answer: "", wrongAnswers: [])
    }
    
    // Computed property for scores
    func getPlayerScore(for player: Player) -> Double {
        let playerTurns = turns.filter { $0.player.id == player.id }
        let correctAnswers = playerTurns.filter { $0.wasCorrect }
        return Double(correctAnswers.count)
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
        
        // Find players with winning score
        let playersWithWinningScore = playerScores.filter { $0.score >= GameConstants.Game.winningScore }
        
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
        players.contains { getPlayerScore(for: $0) >= GameConstants.Game.winningScore }
    }
    
    init(
        player1Name: String = "Player 1", 
        player2Name: String = "Player 2",
        category: TriviaCategory = .bible,
        questionRepository: QuestionRepositoryProtocol
    ) {
        self.players = [
            Player(id: UUID().uuidString, name: player1Name),
            Player(id: UUID().uuidString, name: player2Name)
        ]
        self.category = category
        self.questionRepository = questionRepository
        
        startNewTurn()
    }
    
    func startNewTurn() {
        // Create turn with player first
        currentTurn = Turn(player: currentPlayer)
        
        // Then load the question
        do {
            let question = try questionRepository.nextQuestion(category: category)
            currentTurn?.question = question
        } catch {
            print("Failed to get question: \(error)")
            // Fallback to a default question or handle error appropriately
        }
    }
    
    func answeredCorrect() {
        recordAnswer(wasCorrect: true)
        nextTurn()
    }
    
    func answeredWrong() {
        recordAnswer(wasCorrect: false)
        nextTurn()
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
    
    private func nextTurn() {
        // Check if game should end (when a player reaches 10 points)
        if shouldEndGame {
            gameEnded = true
            return
        }
        
        // Switch to next player
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        startNewTurn()
    }
    
    func resetGame() {
        turns.removeAll()
        questionRepository.resetUsedQuestions()
        currentPlayerIndex = 0
        showAnswer = false
        gameEnded = false
        startNewTurn()
    }
    
    func showAnswerToggle() {
        showAnswer.toggle()
    }
    
    // MARK: - Update Player Names
    
    func updatePlayer1Name(_ newName: String) {
        guard !newName.isEmpty else { return }
        players[0] = Player(id: players[0].id, name: newName)
    }
    
    func updatePlayer2Name(_ newName: String) {
        guard !newName.isEmpty else { return }
        players[1] = Player(id: players[1].id, name: newName)
    }
}



struct Player {
    let id: String
    let name: String
}

struct Question {
    let id: String
    let question: String
    let answer: String
    let wrongAnswers: [String]
}

struct Turn {
    let player: Player
    var question: Question?
    var isAnswered: Bool = false
    var wasCorrect: Bool = false
}

@Observable
class SinglePlayerGameViewModel {
    let player: Player
    private let questionRepository: QuestionRepositoryProtocol
    private let category: TriviaCategory
    private var gameStartTime: Date?
    private var timer: Timer?
    
    var turns: [Turn] = []
    var currentTurn: Turn?
    var gameEnded = false
    var hasAnswered = false
    var showResults = false
    var selectedAnswer: String?
    var currentAnswerOptions: [String] = []
    var elapsedTime: TimeInterval = 0
    
    // Action log for undo functionality
    var actionLog: [String] = []
    
    var currentQuestion: Question {
        currentTurn?.question ?? Question(id: "default", question: "", answer: "", wrongAnswers: [])
    }
    
    // Computed property for score
    func getPlayerScore() -> Double {
        let playerTurns = turns.filter { $0.player.id == player.id }
        let correctAnswers = playerTurns.filter { $0.wasCorrect }
        return Double(correctAnswers.count)
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
        getPlayerScore() >= GameConstants.Game.winningScore || turns.count >= GameConstants.Game.maxQuestions
    }
    
    init(
        playerName: String = "Player",
        category: TriviaCategory = .bible,
        questionRepository: QuestionRepositoryProtocol
    ) {
        self.player = Player(id: UUID().uuidString, name: playerName)
        self.category = category
        self.questionRepository = questionRepository
    }
    
    deinit {
        stopTimer()
    }

    /// Start the game - loads the first real question
    func startGame() {
        // Start timer when game begins
        startTimer()
        startNewTurn()
    }
    
    func startNewTurn() {
        hasAnswered = false
        showResults = false
        selectedAnswer = nil
        
        // Create turn with player first
        currentTurn = Turn(player: player)
        
        // Then load the question with proper error handling
        do {
            let question = try questionRepository.nextQuestion(category: category)
            print("SinglePlayerGameViewModel: Got question: \(question.question)")
            
            // Update the turn and generate options atomically
            currentTurn?.question = question
            generateAnswerOptions()
            
        } catch {
            print("Failed to load question: \(error)")
        }
    }
    
    private func generateAnswerOptions() {
        guard let question = currentTurn?.question else { 
            currentAnswerOptions = ["Error loading options"]
            return 
        }

        // Validate question has required data
        guard !question.answer.isEmpty else {
            currentAnswerOptions = ["Error: Invalid question data"]
            return
        }

        // Combine wrong answers with the correct answer
        var combined = question.wrongAnswers + [question.answer]
        
        // Remove empty strings that might cause issues
        combined = combined.filter { !$0.isEmpty }
        
        // Ensure we have the correct answer
        if !combined.contains(question.answer) {
            combined.append(question.answer)
        }

        // Deduplicate while preserving order
        var unique: [String] = []
        var seen = Set<String>()
        for option in combined {
            if seen.insert(option).inserted {
                unique.append(option)
            }
        }

        // Ensure we have at least 3 unique options by padding with safe fillers
        // (This protects against malformed data where a wrong answer duplicates the correct answer.)
        let fillers = ["Option A", "Option B", "Option C", "Option D", "Option E"]
        var fillerIndex = 0
        while unique.count < 3 && fillerIndex < fillers.count {
            let filler = fillers[fillerIndex]
            fillerIndex += 1
            if !seen.contains(filler) {
                unique.append(filler)
                seen.insert(filler)
            }
        }

        // Final safety check - must have at least 2 options
        if unique.count < 2 {
            print("ERROR: Unable to generate sufficient answer options")
            unique = [question.answer, "No other options available"]
        }

        // Shuffle for presentation
        unique.shuffle()
        currentAnswerOptions = unique
    }

    
    func selectAnswer(_ answer: String) {
        // Validate the answer is in current options
        guard currentAnswerOptions.contains(answer) else {
            return
        }
        
        // Don't allow selection if showing results
        guard !showResults else {
            return
        }
        
        // Additional safety: ensure we have a valid current question
        guard let currentTurn = currentTurn, 
              let question = currentTurn.question,
              !question.answer.isEmpty else {
            return
        }
        
        selectedAnswer = answer
        
        // Auto-reveal results when answer is selected
        revealResults()
    }
    
    func revealResults() {
        guard let answer = selectedAnswer else { 
            return 
        }
        
        // Additional safety check
        guard let currentTurn = currentTurn,
              let question = currentTurn.question else {
            return
        }
        
        showResults = true
        
        let wasCorrect = answer == question.answer
        
        // Add to action log
        let actionText = wasCorrect ? "✓ Answered correctly" : "✗ Answered incorrectly"
        actionLog.append(actionText)
        
        recordAnswer(wasCorrect: wasCorrect)
        
        // Don't automatically progress - wait for Continue button
    }
    
    func continueToNextQuestion() {
        // If results are already showing, move to next question
        if showResults {
            // Check if game should end
            if shouldEndGame {
                gameEnded = true
                return
            }
            
            actionLog.append("→ Next question")
            startNewTurn()
        } else {
            // If results aren't showing yet, this shouldn't happen since we auto-reveal
            hasAnswered = true
            revealResults()
        }
    }
    
    // MARK: - Undo Functionality
    
    func undoLastAction() {
        guard !turns.isEmpty else { return }
        
        // Remove last turn
        let removedTurn = turns.removeLast()
        
        // Remove last 2 actions from log (the answer action and the "next question" action)
        if !actionLog.isEmpty {
            actionLog.removeLast() // Remove "next question"
        }
        if !actionLog.isEmpty {
            actionLog.removeLast() // Remove answer result
        }
        
        // Restore the previous question
        currentTurn = removedTurn
        selectedAnswer = nil
        showResults = false
        hasAnswered = false
    }
    
    var canUndo: Bool {
        !turns.isEmpty && !gameEnded
    }
    
    private func recordAnswer(wasCorrect: Bool) {
        guard var turn = currentTurn else { 
            print("ERROR: Cannot record answer - no current turn")
            return 
        }
        
        // Additional safety
        guard turn.question != nil else {
            print("ERROR: Cannot record answer - turn has no question")
            return
        }
        
        // Update the current turn with answer information
        turn.isAnswered = true
        turn.wasCorrect = wasCorrect
        
        // Add the completed turn to answered questions
        turns.append(turn)
        
        // Update current turn to reflect the answered state
        currentTurn = turn
        
        print("Recorded answer: \(wasCorrect ? "correct" : "incorrect"). Total score: \(getPlayerScore())")
    }
    
    private func nextTurn() {
        // Check if game should end
        if shouldEndGame {
            stopTimer()
            gameEnded = true
            return
        }
        
        startNewTurn()
    }
    
    private func startTimer() {
        gameStartTime = Date()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.gameStartTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
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
        showResults = false
        selectedAnswer = nil
        gameEnded = false
        stopTimer()
        startTimer()
        startNewTurn()
    }
}

