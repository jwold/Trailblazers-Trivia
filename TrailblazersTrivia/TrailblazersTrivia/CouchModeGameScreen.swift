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
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}

struct CouchModeGameScreen: View {
    @Binding var path: [Routes]
    @State private var gameViewModel: GameViewModel
    @State private var showPassDevicePrompt = false
    @State private var selectedAnswer: String?
    @State private var showResults = false
    
    init(path: Binding<[Routes]>, category: TriviaCategory) {
        self._path = path
        
        // Generate team names based on category
        let teamNames = TeamNameGenerator.generateTeamNames(for: category)
        self._gameViewModel = State(initialValue: GameViewModel(
            player1Name: teamNames.team1,
            player2Name: teamNames.team2,
            category: category
        ))
    }
    
    var body: some View {
        ZStack {
            // Clean background
            GrayTheme.background
                .ignoresSafeArea()
            
            if showPassDevicePrompt {
                passDeviceOverlay
            } else if gameViewModel.gameEnded {
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
    }
    
    // MARK: - Game Content
    private var gameContentView: some View {
        VStack(spacing: 0) {
            // Content Section
            VStack(alignment: .leading, spacing: 20) {
                // Player info header
                HStack(alignment: .center, spacing: 0) {
                    // Current player indicator
                    HStack(spacing: 12) {
                        Text("\(gameViewModel.currentPlayer.name)'s Turn")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(GrayTheme.gold)
                        
                        Text("\(ScoreFormatter.format(gameViewModel.currentPlayerScore))/10")
                            .font(.headline)
                            .foregroundColor(GrayTheme.text.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(GrayTheme.lightCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(GrayTheme.gold.opacity(0.5), lineWidth: 2)
                            )
                    )
                    
                    Spacer()
                    
                    Button {
                        path = []
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.black.opacity(0.85))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(GrayTheme.text.opacity(0.15))
                            )
                    }
                }
                .padding(.horizontal, 12)
                
                // Score summary
                HStack(spacing: 16) {
                    playerScoreCard(player: gameViewModel.player1, score: gameViewModel.getPlayerScore(for: gameViewModel.player1), isCurrent: gameViewModel.currentPlayer.id == gameViewModel.player1.id)
                    playerScoreCard(player: gameViewModel.player2, score: gameViewModel.getPlayerScore(for: gameViewModel.player2), isCurrent: gameViewModel.currentPlayer.id == gameViewModel.player2.id)
                }
                .padding(.horizontal, 12)
                
                // Question Text
                VStack(alignment: .leading, spacing: 12) {
                    Text(gameViewModel.currentQuestion.question)
                        .font(.system(size: 34, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(GrayTheme.text)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(GrayTheme.card, in: RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.12), .white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
                .padding(.horizontal, 12)
                
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
    
    // MARK: - Player Score Card
    private func playerScoreCard(player: Player, score: Double, isCurrent: Bool) -> some View {
        VStack(spacing: 4) {
            Text(player.name)
                .font(.caption)
                .foregroundColor(GrayTheme.text.opacity(0.7))
            Text("\(ScoreFormatter.format(score))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isCurrent ? GrayTheme.gold : GrayTheme.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrent ? GrayTheme.card : GrayTheme.accent)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCurrent ? GrayTheme.gold.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Answer Buttons
    private var answerButtonsView: some View {
        let options = [gameViewModel.currentQuestion.answer] + gameViewModel.currentQuestion.wrongAnswers
        let shuffledOptions = options.shuffled()
        
        return VStack(spacing: 16) {
            ForEach(Array(shuffledOptions.enumerated()), id: \.offset) { index, option in
                Button {
                    selectAnswer(option)
                } label: {
                    HStack(spacing: 16) {
                        Text(option)
                            .font(.system(size: 18, weight: .medium))
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(GrayTheme.accent)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                buttonBorderColor(for: option),
                                lineWidth: buttonBorderWidth(for: option)
                            )
                    )
                    .scaleEffect(buttonScale(for: option))
                    .opacity(buttonOpacity(for: option))
                }
                .disabled(showResults)
            }
        }
        .padding(.horizontal, 20)
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
        .padding(.horizontal, 20)
    }
    
    // MARK: - Pass Device Overlay
    private var passDeviceOverlay: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 80, weight: .light))
                .foregroundColor(GrayTheme.gold)
            
            Text("Pass to \(gameViewModel.currentPlayer.name)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(GrayTheme.text)
            
            Text("Hand the device to the next player")
                .font(.title3)
                .foregroundColor(GrayTheme.text.opacity(0.7))
            
            Button {
                withAnimation {
                    showPassDevicePrompt = false
                }
            } label: {
                Text("I'm Ready")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.9))
                    .frame(width: 200)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(GrayTheme.gold)
                    )
                    .shadow(color: GrayTheme.gold.opacity(0.35), radius: 10, x: 0, y: 4)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GrayTheme.background.opacity(0.98))
    }
    
    // MARK: - Actions
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        showResults = true
        
        let wasCorrect = answer == gameViewModel.currentQuestion.answer
        if wasCorrect {
            gameViewModel.answeredCorrect()
        } else {
            gameViewModel.answeredWrong()
        }
    }
    
    private func nextQuestion() {
        selectedAnswer = nil
        showResults = false
        
        if gameViewModel.shouldEndGame {
            gameViewModel.gameEnded = true
        } else {
            showPassDevicePrompt = true
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

#Preview {
    CouchModeGameScreen(path: .constant([]), category: .bible)
}
