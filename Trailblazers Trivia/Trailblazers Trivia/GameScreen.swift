//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

struct GameScreen: View {
    @Binding var path: [Routes]
    @State private var gameViewModel = GameViewModel(player1Name: "Persian", player2Name: "Player 2")
    @State private var selectedDifficulty = 1 // 0 = Easy, 1 = Hard
    
    let selectedCategory: String = "Bible"
    
    var body: some View {
        ZStack {
            // Clean background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Difficulty Segmented Control - Stocks app style
                VStack(spacing: 16) {
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        Text("Easy").tag(0)
                        Text("Hard").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    .onChange(of: selectedDifficulty) { _ in
                        gameViewModel.resetGame()
                        gameViewModel.setNextQuestion(difficulty: selectedDifficulty == 0 ? .easy : .hard)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Player info above question
                    HStack {
                        Spacer()
                        Text("\(gameViewModel.currentPlayer.name)'s Turn • \(gameViewModel.currentPlayerScore) Points")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Question Text - larger and centered
                    HStack {
                        Spacer()
                        Text(gameViewModel.currentQuestion.question)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Answer Display (when shown)
                    if gameViewModel.showAnswer {
                        VStack(spacing: 16) {
                            Text(gameViewModel.currentQuestion.answer)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .primary.opacity(0.08), radius: 12, x: 0, y: 6)
                        .shadow(color: .primary.opacity(0.04), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Bottom Buttons Section
                VStack(spacing: 16) {
                    if !gameViewModel.showAnswer {
                        Button {
                            gameViewModel.showAnswerToggle()
                        } label: {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .font(.headline)
                                Text("Show Answer")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .shadow(color: .blue.opacity(0.25), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Action Buttons
                        VStack(spacing: 16) {
                            Button {
                                gameViewModel.answerCorrect()
                                gameViewModel.setNextQuestion(difficulty: selectedDifficulty == 0 ? .easy : .hard)
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.headline)
                                    Text("Correct")
                                        .fontWeight(.semibold)
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                                .shadow(color: .green.opacity(0.25), radius: 8, x: 0, y: 4)
                            }
                            
                            Button {
                                gameViewModel.answerWrong()
                                gameViewModel.setNextQuestion(difficulty: selectedDifficulty == 0 ? .easy : .hard)
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.headline)
                                    Text("Wrong")
                                        .fontWeight(.semibold)
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                                .shadow(color: .red.opacity(0.25), radius: 8, x: 0, y: 4)
                            }
                            
                            Button {
                                gameViewModel.showAnswerToggle()
                            } label: {
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .font(.subheadline)
                                    Text("Hide Answer")
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .strokeBorder(.quaternary, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    path.removeLast()
                }
                .foregroundColor(.blue)
                .font(.headline)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: Routes.results) {
                    Text("End")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            }
        }
    }
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

#Preview {
    GameScreen(path: .constant([]))
}
