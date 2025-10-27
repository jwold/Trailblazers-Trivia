//
//  SinglePlayerGameScreen.swift
//  Trailblazers Trivia
//
//  Created by AI Assistant on 10/17/25.
//

import SwiftUI

private enum GrayTheme {
    static let background = Color(white: 0.04)      // deeper dark for higher contrast
    static let card = Color(white: 0.10)            // darker card for separation
    static let lightCard = Color(white: 0.16)       // darker chip/track for contrast
    static let text = Color(white: 1.0)             // pure white text for maximum contrast
    static let accent = Color(white: 0.22)          // dark accent for white text contrast
    static let success = Color(white: 0.22)         // dark success for white text contrast
    static let error = Color(white: 0.90)           // bright error text on dark bg
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0) // #FFD700 bright gold
}

struct SinglePlayerGameScreen: View {
    @Binding var path: [Routes]
    let category: TriviaCategory
    @State private var singlePlayerViewModel: SinglePlayerGameViewModel
    
    init(path: Binding<[Routes]>, category: TriviaCategory) {
        self._path = path
        self.category = category
        
        // Generate a random team name for single player based on category
        let teamName = TeamNameGenerator.randomTeamName(for: category)
        self._singlePlayerViewModel = State(initialValue: SinglePlayerGameViewModel(playerName: teamName))
    }
    
    var body: some View {
        ZStack {
            // Clean background
            GrayTheme.background
                .ignoresSafeArea()
            
            if singlePlayerViewModel.isLoading {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: GrayTheme.accent))
                        .scaleEffect(1.5)
                    
                    Text("Loading Questions...")
                        .font(.headline)
                        .foregroundColor(GrayTheme.text)
                    
                    if let error = singlePlayerViewModel.loadingError {
                        Text("Error: \(error)")
                            .font(.caption)
                            .foregroundColor(GrayTheme.error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Game content
                gameContentView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onChange(of: singlePlayerViewModel.gameEnded) { _, gameEnded in
            if gameEnded {
                let finalScore = singlePlayerViewModel.getPlayerScore()
                let questionsAnswered = singlePlayerViewModel.turns.count
                let elapsedTime = singlePlayerViewModel.elapsedTime
                path.append(Routes.singlePlayerResults(finalScore: finalScore, questionsAnswered: questionsAnswered, elapsedTime: elapsedTime))
            }
        }
    }
    
    private var gameContentView: some View {
            VStack(spacing: 0) {
                                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Player info above question
                    HStack(alignment: .center, spacing: 0) {
                        // Single player score box - matching two-player style
                        HStack(spacing: 8) {
                            Text("\(ScoreFormatter.format(singlePlayerViewModel.getPlayerScore()))/10 Points • \(singlePlayerViewModel.formatElapsedTime())")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(GrayTheme.text)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(GrayTheme.lightCard)
                                .stroke(GrayTheme.text.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
                        .padding(.bottom, 8)
                        
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
                    
                    // Question Text - sized to content
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Question text
                            Text(singlePlayerViewModel.currentQuestion.question)
                                .font(.system(size: 34, weight: .medium))
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(GrayTheme.text)
                        }
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
                    .shadow(color: .primary.opacity(0.08), radius: 12, x: 0, y: 6)
                    .shadow(color: .primary.opacity(0.04), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 12)
                    
                    // Answer buttons right below question card
                    if !singlePlayerViewModel.isLoading {
                        answerButtonsView
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 0)
                .padding(.top, 60)
                .frame(maxHeight: .infinity)
            }
        .safeAreaInset(edge: .bottom) {
            if !singlePlayerViewModel.isLoading {
                continueButtonView
            }
        }
    }
    
    private var continueButtonView: some View {
        Button {
            Task {
                await singlePlayerViewModel.continueToNextQuestion()
            }
        } label: {
            Text("Continue")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(singlePlayerViewModel.selectedAnswer != nil ? .black.opacity(0.9) : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(singlePlayerViewModel.selectedAnswer != nil ? GrayTheme.gold : GrayTheme.success.opacity(0.5))
                )
                .shadow(color: (singlePlayerViewModel.selectedAnswer != nil ? GrayTheme.gold.opacity(0.35) : Color.clear), radius: 10, x: 0, y: 4)
        }
        .disabled(singlePlayerViewModel.selectedAnswer == nil)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .background(GrayTheme.background)
    }
    
    private var answerButtonsView: some View {
        // Multiple choice answers - positioned right below question card
        VStack(spacing: 16) {
            ForEach(singlePlayerViewModel.currentAnswerOptions, id: \.self) { option in
                Button {
                    singlePlayerViewModel.selectAnswer(option)
                } label: {
                    HStack(spacing: 16) {
                        // Circle icon on the left - radio button style
                        ZStack {
                            Circle()
                                .stroke((singlePlayerViewModel.showResults && option == singlePlayerViewModel.currentQuestion.answer) ? Color.clear : Color.white, lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            // Show different states based on selection and results
                            if singlePlayerViewModel.selectedAnswer == option && !singlePlayerViewModel.showResults {
                                // Selected but not revealed yet - filled circle (radio button)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 12)
                            } else if singlePlayerViewModel.showResults && option == singlePlayerViewModel.currentQuestion.answer {
                                // Results revealed and this is correct - checkmark
                                ZStack {
                                    Circle()
                                        .fill(GrayTheme.gold)
                                        .frame(width: 22, height: 22)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            } else if singlePlayerViewModel.showResults && option == singlePlayerViewModel.selectedAnswer && option != singlePlayerViewModel.currentQuestion.answer {
                                // Results revealed and this was selected but wrong - X mark
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Answer text
                        Text(option)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(buttonColor(for: option))
                    )
                    .overlay(
                        // White outline for selected answer (before results) or correct answer (after results)
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                Color.white,
                                lineWidth: (singlePlayerViewModel.selectedAnswer == option && !singlePlayerViewModel.showResults) ? 4 : 0
                            )
                    )
                    .scaleEffect(
                        // Slight growth for selected answer or correct answer
                        (singlePlayerViewModel.selectedAnswer == option && !singlePlayerViewModel.showResults) || 
                        (singlePlayerViewModel.showResults && option == singlePlayerViewModel.currentQuestion.answer) ? 1.05 : 1.0
                    )
                    .animation(.easeInOut(duration: 0.2), value: singlePlayerViewModel.selectedAnswer)
                    .animation(.easeInOut(duration: 0.2), value: singlePlayerViewModel.showResults)
                    .opacity(singlePlayerViewModel.selectedAnswer == nil || singlePlayerViewModel.selectedAnswer == option || singlePlayerViewModel.showResults ? 1.0 : 0.6)
                }
                .disabled(singlePlayerViewModel.showResults) // Only disable after results are shown
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func buttonColor(for option: String) -> Color {
        // Keep all buttons the same color - don't change to green or red
        return GrayTheme.accent
    }
}

#Preview {
    SinglePlayerGameScreen(path: .constant([]), category: .bible)
}

