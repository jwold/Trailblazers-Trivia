//
//  CouchModeGameScreen.swift
//  TrailblazersTrivia
//
//  Created by AI Assistant on 11/18/25.
//

import SwiftUI

private enum GrayTheme {
    static let background = Color(white: 0.04)
    static let card = Color(white: 0.10)
    static let lightCard = Color(white: 0.16)
    static let text = Color(white: 1.0)
    static let accent = Color(white: 0.22)
    static let gold = Color(red: 0.35, green: 0.55, blue: 0.77) // #5A8BC4 blue
}

struct CouchModeGameScreen: View {
    @Binding var path: [Routes]
    @State private var gameViewModel: GameViewModel
    @State private var selectedAnswer: String?
    @State private var showResults = false
    @State private var showInfoModal = false
    @State private var shuffledAnswers: [String] = []
    
    init(path: Binding<[Routes]>, category: TriviaCategory) {
        self._path = path
        
        // Generate team names based on category
        let teamNames = TeamNameGenerator.generateTeamNames(for: category)
        self._gameViewModel = State(initialValue: GameViewModel(
            player1Name: teamNames.team1,
            player2Name: teamNames.team2,
            category: category,
            questionRepository: JSONQuestionRepository()
        ))
    }
    
    var body: some View {
        ZStack {
            // Clean background
            GrayTheme.background
                .ignoresSafeArea()
            
            if gameViewModel.gameEnded {
                // Navigate to results
                Color.clear
                    .onAppear {
                        path.append(Routes.results(playerScores: gameViewModel.getAllPlayerScores()))
                    }
            } else {
                gameContentView
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showInfoModal) {
            CouchModeInfoModalView()
        }
        .onAppear {
            shuffleAnswers()
        }
        .onChange(of: gameViewModel.currentQuestion.id) { _, _ in
            shuffleAnswers()
        }
    }
    
    // MARK: - Game Content
    private var gameContentView: some View {
        VStack(spacing: 0) {
            // Content Section
            VStack(alignment: .leading, spacing: 20) {
                // Player info above question - same as Shout Out Mode
                HStack(alignment: .center, spacing: 0) {
                    // Back button
                    Button {
                        path = []
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(GrayTheme.text)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Connected team boxes - aligned with question card
                    HStack(spacing: 0) {
                        // Player 1 section
                        HStack(spacing: 8) {
                            Text(gameViewModel.player1.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? .black.opacity(0.9) : GrayTheme.text.opacity(0.8))
                                .lineLimit(1)
                            
                            Text(ScoreFormatter.format(gameViewModel.getPlayerScore(for: gameViewModel.player1)))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? .black.opacity(0.9) : GrayTheme.text.opacity(0.8))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? GrayTheme.gold : Color.clear)
                        )
                        
                        // Player 2 section
                        HStack(spacing: 8) {
                            Text(gameViewModel.player2.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? .black.opacity(0.9) : GrayTheme.text.opacity(0.8))
                                .lineLimit(1)
                            
                            Text(ScoreFormatter.format(gameViewModel.getPlayerScore(for: gameViewModel.player2)))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? .black.opacity(0.9) : GrayTheme.text.opacity(0.8))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? GrayTheme.gold : Color.clear)
                        )
                    }
                    .frame(maxWidth: 280)
                    
                    Spacer()
                    
                    // Info button
                    Button {
                        showInfoModal = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.headline)
                            .foregroundColor(GrayTheme.text)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 12)
                }
                .padding(.horizontal, 24)
                
                // Question Text
                VStack(alignment: .leading, spacing: 12) {
                    Text(gameViewModel.currentQuestion.question)
                        .font(.system(size: 34, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(GrayTheme.text)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                
                // Answer buttons
                if !gameViewModel.showAnswer {
                    answerButtonsView
                        .padding(.top, 20)
                }
                
                // Continue button
                if showResults {
                    continueButton
                        .padding(.top, 30)
                }
                
                Spacer()
            }
            .padding(.horizontal, 0)
            .padding(.top, 60)
            .frame(maxHeight: .infinity)
        }
    }
    
    // MARK: - Answer Buttons
    private var answerButtonsView: some View {
        VStack(spacing: 16) {
            ForEach(Array(shuffledAnswers.enumerated()), id: \.offset) { index, option in
                Button {
                    selectAnswer(option)
                } label: {
                    HStack(spacing: 16) {
                        Text(option)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(answerTextColor(for: option))
                            .strikethrough(shouldStrikethrough(option), color: .white.opacity(0.5))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if showResults {
                            if option == gameViewModel.currentQuestion.answer {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(GrayTheme.gold)
                            } else if option == selectedAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .opacity(buttonOpacity(for: option))
                }
                .disabled(showResults)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Continue Button
    private var continueButton: some View {
        Button {
            nextQuestion()
        } label: {
            Text("Continue")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(GrayTheme.gold)
                )
                .shadow(color: GrayTheme.gold.opacity(0.35), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Actions
    private func shuffleAnswers() {
        let options = [gameViewModel.currentQuestion.answer] + gameViewModel.currentQuestion.wrongAnswers
        shuffledAnswers = options.shuffled()
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        showResults = true
    }
    
    private func nextQuestion() {
        // Award points based on selected answer
        let wasCorrect = selectedAnswer == gameViewModel.currentQuestion.answer
        if wasCorrect {
            gameViewModel.answeredCorrect()
        } else {
            gameViewModel.answeredWrong()
        }
        
        // Reset state
        selectedAnswer = nil
        showResults = false
        
        // Shuffle answers for next question
        shuffleAnswers()
        
        // Check if game should end
        if gameViewModel.shouldEndGame {
            gameViewModel.gameEnded = true
        }
    }
    
    // MARK: - Styling Helpers
    private func answerTextColor(for option: String) -> Color {
        if showResults {
            if option == gameViewModel.currentQuestion.answer {
                return .white
            } else if option == selectedAnswer {
                return .white.opacity(0.5)
            } else {
                return .white.opacity(0.4)
            }
        }
        return .white
    }
    
    private func shouldStrikethrough(_ option: String) -> Bool {
        return showResults && option == selectedAnswer && option != gameViewModel.currentQuestion.answer
    }
    
    private func buttonBorderColor(for option: String) -> Color {
        if showResults && option == gameViewModel.currentQuestion.answer {
            return GrayTheme.gold
        } else if selectedAnswer == option && !showResults {
            return .white
        }
        return .clear
    }
    
    private func buttonBorderWidth(for option: String) -> CGFloat {
        if showResults && option == gameViewModel.currentQuestion.answer {
            return 3
        } else if selectedAnswer == option && !showResults {
            return 4
        }
        return 0
    }
    
    private func buttonScale(for option: String) -> CGFloat {
        if (selectedAnswer == option && !showResults) ||
           (showResults && option == gameViewModel.currentQuestion.answer) {
            return 1.05
        }
        return 1.0
    }
    
    private func buttonOpacity(for option: String) -> Double {
        if showResults {
            if option == gameViewModel.currentQuestion.answer {
                return 1.0
            }
            return 0.6
        }
        return selectedAnswer == nil || selectedAnswer == option ? 1.0 : 0.6
    }
}

// MARK: - Couch Mode Info Modal View

struct CouchModeInfoModalView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GrayTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Spacer()
                    Text("How to Play")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(GrayTheme.text)
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(GrayTheme.text.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(GrayTheme.card)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.2.fill")
                                .font(.title2)
                                .foregroundColor(GrayTheme.gold)
                            Text("Couch Mode")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(GrayTheme.text)
                        }
                        
                        Text("This mode is designed for two players taking turns on the same device. Pass the device back and forth after each question.")
                            .font(.body)
                            .foregroundColor(GrayTheme.text.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(GrayTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [GrayTheme.text.opacity(0.12), GrayTheme.text.opacity(0.04)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    
                    // Instructions list
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionRow(number: "1", text: "Current player reads and answers the question")
                        InstructionRow(number: "2", text: "Select your answer from the multiple choice options")
                        InstructionRow(number: "3", text: "Tap 'Submit Answer' to see if you're correct")
                        InstructionRow(number: "4", text: "Pass the device to the next player")
                        InstructionRow(number: "5", text: "First to 10 points wins!")
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Close button
                Button {
                    dismiss()
                } label: {
                    Text("Got it!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(GrayTheme.gold)
                        )
                        .shadow(color: GrayTheme.gold.opacity(0.35), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    CouchModeGameScreen(path: .constant([]), category: .bible)
}
