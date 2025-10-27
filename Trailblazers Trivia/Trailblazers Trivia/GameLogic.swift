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
        currentTurn?.question ?? Question(id: "default", question: "Loading...", answer: "...", wrongAnswers: ["Loading...", "Loading..."])
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
        let playersWithWinningScore = playerScores.filter { $0.score >= GameConstants.Scoring.winningScore }
        
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
        players.contains { getPlayerScore(for: $0) >= GameConstants.Scoring.winningScore }
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
        self.questionRepository = questionRepository ?? MemoryQuestionRepository()
        
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
            let question = try await questionRepository.nextQuestion()
            currentTurn?.question = question
        } catch {
            print("Failed to get question: \(error)")
            // Fallback to a default question or handle error appropriately
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
    var isLoading = true
    var loadingError: String?
    
    var currentQuestion: Question {
        currentTurn?.question ?? Question(id: "default", question: "Loading...", answer: "...", wrongAnswers: ["Loading...", "Loading..."])
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
        getPlayerScore() >= GameConstants.SinglePlayer.winningScore || turns.count >= GameConstants.SinglePlayer.maxQuestions
    }
    
    init(
        playerName: String = "Player",
        category: TriviaCategory = .bible,
        questionRepository: QuestionRepositoryProtocol? = nil
    ) {
        print("SinglePlayerGameViewModel initializing...")
        self.player = Player(id: UUID().uuidString, name: playerName)
        // Use memory repository for now to avoid JSON loading issues
        self.questionRepository = questionRepository ?? MemoryQuestionRepository()
        
        // Set up a default question immediately to prevent crashes
        self.currentTurn = Turn(player: Player(id: UUID().uuidString, name: playerName))
        self.currentTurn?.question = Question(
            id: "loading",
            question: "Loading...",
            answer: "Loading...",
            wrongAnswers: ["Loading...", "Loading..."]
        )
        self.currentAnswerOptions = ["Loading...", "Loading...", "Loading..."]
        
        startTimer()
        print("SinglePlayerGameViewModel initialized")
    }
    
    /// Start the game - loads the first real question
    @MainActor
    func startGame() async {
        print("SinglePlayerGameViewModel: Starting game...")
        await startNewTurn()
    }
    
    @MainActor
    func startNewTurn() async {
        print("SinglePlayerGameViewModel: startNewTurn called")
        isLoading = true
        hasAnswered = false
        showResults = false
        selectedAnswer = nil
        
        // Create turn with player first
        currentTurn = Turn(player: player)
        
        // Then load the question with proper error handling
        do {
            let question = try await questionRepository.nextQuestion()
            print("SinglePlayerGameViewModel: Got question: \(question.question)")
            currentTurn?.question = question
            generateAnswerOptions()
            loadingError = nil
        } catch {
            print("SinglePlayerGameViewModel: Failed to get question: \(error)")
            loadingError = "Failed to load question: \(error.localizedDescription)"
            
            // Provide a fallback question to keep the game playable
            let fallbackQuestion = Question(
                id: "fallback",
                question: "Who was the first man created by God?",
                answer: "Adam",
                wrongAnswers: ["Seth", "Noah"]
            )
            currentTurn?.question = fallbackQuestion
            generateAnswerOptions()
        }
        
        isLoading = false
        print("SinglePlayerGameViewModel: startNewTurn completed, isLoading = \(isLoading)")
    }
    
    private func generateAnswerOptions() {
        guard let question = currentTurn?.question else { return }

        // Combine wrong answers with the correct answer
        let combined = question.wrongAnswers + [question.answer]

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

        // Shuffle for presentation
        unique.shuffle()
        currentAnswerOptions = unique
    }

    
    func selectAnswer(_ answer: String) {
        // Allow changing answers freely - don't set hasAnswered flag
        selectedAnswer = answer
    }
    
    func revealResults() {
        guard let answer = selectedAnswer else { return }
        
        showResults = true
        
        let wasCorrect = answer == currentQuestion.answer
        recordAnswer(wasCorrect: wasCorrect)
        
        // Don't automatically progress - wait for Continue button
    }
    
    @MainActor
    func continueToNextQuestion() async {
        print("SinglePlayerGameViewModel: continueToNextQuestion called, showResults = \(showResults)")
        
        if !showResults {
            // First press: reveal the results and mark as answered
            hasAnswered = true
            revealResults()
        } else {
            // Second press: move to next question
            // Check if game should end
            if shouldEndGame {
                print("SinglePlayerGameViewModel: Game should end, setting gameEnded = true")
                gameEnded = true
                return
            }
            
            print("SinglePlayerGameViewModel: Starting next turn...")
            await startNewTurn()
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
        showResults = false
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

