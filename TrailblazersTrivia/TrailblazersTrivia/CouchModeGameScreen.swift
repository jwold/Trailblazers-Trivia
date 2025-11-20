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
    @State private var showEditPlayer1 = false
    @State private var showEditPlayer2 = false
    @State private var editingPlayer1Name = ""
    @State private var editingPlayer2Name = ""
    
    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
    init(path: Binding<[Routes]>, category: TriviaCategory) {
        self._path = path
        
        // Generate player names for Couch Mode (2P)
        let teamNames = TeamNameGenerator.generateTeamNames(for: category, isCouchMode: true)
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
        .sheet(isPresented: $showEditPlayer1) {
            EditPlayerNameSheet(
                playerNumber: 1,
                currentName: $editingPlayer1Name,
                onSave: {
                    TeamNameStorage.couchPlayer1Name = editingPlayer1Name
                    gameViewModel.updatePlayer1Name(editingPlayer1Name)
                }
            )
        }
        .sheet(isPresented: $showEditPlayer2) {
            EditPlayerNameSheet(
                playerNumber: 2,
                currentName: $editingPlayer2Name,
                onSave: {
                    TeamNameStorage.couchPlayer2Name = editingPlayer2Name
                    gameViewModel.updatePlayer2Name(editingPlayer2Name)
                }
            )
        }
        .onAppear {
            shuffleAnswers()
            impactLight.prepare()
            impactMedium.prepare()
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
                        impactLight.impactOccurred()
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
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Text(gameViewModel.player1.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(GrayTheme.text)
                                
                                TickerTapeScore(
                                    score: gameViewModel.getPlayerScore(for: gameViewModel.player1),
                                    font: .subheadline,
                                    fontWeight: .bold,
                                    foregroundColor: GrayTheme.text
                                )
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(GrayTheme.card)
                                )
                            }
                            
                            Rectangle()
                                .fill(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? GrayTheme.gold : Color.clear)
                                .frame(height: 3)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .onTapGesture {
                            impactLight.impactOccurred()
                            editingPlayer1Name = gameViewModel.player1.name
                            showEditPlayer1 = true
                        }
                        
                        // Player 2 section
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Text(gameViewModel.player2.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(GrayTheme.text)
                                
                                TickerTapeScore(
                                    score: gameViewModel.getPlayerScore(for: gameViewModel.player2),
                                    font: .subheadline,
                                    fontWeight: .bold,
                                    foregroundColor: GrayTheme.text
                                )
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(GrayTheme.card)
                                )
                            }
                            
                            Rectangle()
                                .fill(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? GrayTheme.gold : Color.clear)
                                .frame(height: 3)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .onTapGesture {
                            impactLight.impactOccurred()
                            editingPlayer2Name = gameViewModel.player2.name
                            showEditPlayer2 = true
                        }
                    }
                    .frame(maxWidth: 280)
                    
                    Spacer()
                    
                    // Info button
                    Button {
                        impactLight.impactOccurred()
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
                        .font(.largeTitle)
                        .fontWeight(.medium)
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
                    impactLight.impactOccurred()
                    selectAnswer(option)
                } label: {
                    HStack(spacing: 16) {
                        Text(option)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(answerTextColor(for: option))
                            .strikethrough(shouldStrikethrough(option), color: .white.opacity(0.5))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if showResults {
                            if option == gameViewModel.currentQuestion.answer {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            } else if option == selectedAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(GrayTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(buttonBorderColor(for: option), lineWidth: buttonBorderWidth(for: option))
                            )
                    )
                    .opacity(buttonOpacity(for: option))
                    .contentShape(Rectangle()) // Make entire frame tappable
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(showResults)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Continue Button
    private var continueButton: some View {
        Button {
            impactMedium.impactOccurred()
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
        .buttonStyle(PlainButtonStyle())
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
            return .white
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

// MARK: - Couch Mode Info Modal View (Wrapper for UnifiedInfoModalView)

struct CouchModeInfoModalView: View {
    var body: some View {
        UnifiedInfoModalView()
    }
}

// MARK: - Edit Player Name Sheet

struct EditPlayerNameSheet: View {
    @Environment(\.dismiss) var dismiss
    let playerNumber: Int
    @Binding var currentName: String
    let onSave: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                GrayTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Edit Player \(playerNumber) Name")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(GrayTheme.text)
                        
                        TextField("Enter name", text: $currentName)
                            .font(.title3)
                            .padding()
                            .background(GrayTheme.card)
                            .foregroundColor(GrayTheme.text)
                            .cornerRadius(12)
                            .focused($isTextFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                saveAndDismiss()
                            }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(GrayTheme.text)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAndDismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(GrayTheme.gold)
                    .disabled(currentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .toolbarBackground(GrayTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveAndDismiss() {
        let trimmed = currentName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        currentName = trimmed
        onSave()
        dismiss()
    }
}

#Preview {
    CouchModeGameScreen(path: .constant([]), category: .bible)
}
