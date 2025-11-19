//
//  GameLogic.swift
//  TrailblazersTrivia
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
        questionRepository: QuestionRepositoryProtocol? = nil
    ) {
        self.players = [
            Player(id: UUID().uuidString, name: player1Name),
            Player(id: UUID().uuidString, name: player2Name)
        ]
        self.questionRepository = questionRepository ?? QuestionRepositoryFactory.create(type: .json, category: category)
        
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
    
    // Action log for undo functionality
    var actionLog: [String] = []
    
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
        getPlayerScore() >= GameConstants.Game.winningScore || turns.count >= GameConstants.Game.maxQuestions
    }
    
    init(
        playerName: String = "Player",
        category: TriviaCategory = .bible,
        questionRepository: QuestionRepositoryProtocol? = nil
    ) {
        self.player = Player(id: UUID().uuidString, name: playerName)
        
        // Create question repository
        if let customRepository = questionRepository {
            self.questionRepository = customRepository
        } else {
            self.questionRepository = QuestionRepositoryFactory.create(type: .json, category: category)
        }
        
        // Set up a default question immediately to prevent crashes
        self.currentTurn = Turn(player: Player(id: UUID().uuidString, name: playerName))
        self.currentTurn?.question = Question(
            id: "loading",
            question: "Loading...",
            answer: "Loading...",
            wrongAnswers: ["Loading...", "Loading..."]
        )
        self.currentAnswerOptions = ["Loading...", "Loading...", "Loading..."]
    }
    
    /// Diagnostic function to check for potential crash sources
    func diagnoseIssues() {
        print("\n🔍 DIAGNOSING SINGLE PLAYER ISSUES:")
        print("================================")
        print("Player: \(player.name)")
        print("Current Turn: \(currentTurn != nil ? "✅" : "❌")")
        print("Current Question: \(currentTurn?.question?.question ?? "nil")")
        print("Answer Options: \(currentAnswerOptions)")
        print("Is Loading: \(isLoading)")
        print("Selected Answer: \(selectedAnswer ?? "none")")
        print("Show Results: \(showResults)")
        print("Game Ended: \(gameEnded)")
        print("Loading Error: \(loadingError ?? "none")")
        
        // Test question repository
        Task {
            do {
                let testQuestion = try await questionRepository.nextQuestion()
                print("✅ Question Repository Test: SUCCESS")
                print("   Sample Question: \(testQuestion.question)")
            } catch {
                print("❌ Question Repository Test: FAILED - \(error)")
            }
        }
        
        print("================================\n")
    }
    
    /// Start the game - loads the first real question
    @MainActor
    func startGame() async {
        // Prevent multiple starts
        guard currentAnswerOptions.contains("Loading...") else { 
            return 
        }
        
        // Start timer when game actually begins
        startTimer()
        await startNewTurn()
    }
    
    @MainActor
    func startNewTurn() async {
        
        // Set loading state first
        isLoading = true
        hasAnswered = false
        showResults = false
        selectedAnswer = nil
        
        // Create turn with player first
        currentTurn = Turn(player: player)
        
        // Small delay to ensure UI is in consistent state
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 second
        
        // Then load the question with proper error handling
        do {
            let question = try await questionRepository.nextQuestion()
            print("SinglePlayerGameViewModel: Got question: \(question.question)")
            
            // Update the turn and generate options atomically
            currentTurn?.question = question
            generateAnswerOptions()
            loadingError = nil
            
        } catch {
            loadingError = "Failed to load question: \(error.localizedDescription)"
            
            // Provide multiple fallback questions to keep the game playable
            let fallbackQuestions = [
                Question(id: "fallback1", question: "Who was the first man created by God?", answer: "Adam", wrongAnswers: ["Seth", "Noah", "Abraham"]),
                Question(id: "fallback2", question: "What is the first book of the Bible?", answer: "Genesis", wrongAnswers: ["Exodus", "Matthew", "Psalms"]),
                Question(id: "fallback3", question: "How many days did God take to create the world?", answer: "6 days", wrongAnswers: ["7 days", "5 days", "10 days"]),
                Question(id: "fallback4", question: "What was Noah's ark made of?", answer: "Gopher wood", wrongAnswers: ["Cedar", "Oak", "Pine"]),
                Question(id: "fallback5", question: "Who led the Israelites out of Egypt?", answer: "Moses", wrongAnswers: ["Aaron", "Joshua", "David"])
            ]
            
            // Use a different fallback question each time
            let fallbackIndex = turns.count % fallbackQuestions.count
            let fallbackQuestion = fallbackQuestions[fallbackIndex]
            
            currentTurn?.question = fallbackQuestion
            generateAnswerOptions()
        }
        
        // Only set loading to false after everything is ready
        isLoading = false
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
        combined = combined.filter { !$0.isEmpty && $0 != "Loading..." }
        
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

    
    @MainActor
    func selectAnswer(_ answer: String) {
        // Validate the answer is in current options
        guard currentAnswerOptions.contains(answer) else {
            return
        }
        
        // Don't allow selection if still loading or showing results
        guard !isLoading && !showResults else {
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
    
    @MainActor
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
    
    @MainActor
    func continueToNextQuestion() async {
        // If results are already showing, move to next question
        if showResults {
            // Check if game should end
            if shouldEndGame {
                gameEnded = true
                return
            }
            
            actionLog.append("→ Next question")
            await startNewTurn()
        } else {
            // If results aren't showing yet, this shouldn't happen since we auto-reveal
            hasAnswered = true
            revealResults()
        }
    }
    
    // MARK: - Undo Functionality
    
    @MainActor
    func undoLastAction() async {
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

