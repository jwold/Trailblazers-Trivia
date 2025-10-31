//
//  SinglePlayerGameScreen.swift
//  TrailblazersTrivia
//
//  Created by AI Assistant on 10/17/25.
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

struct SinglePlayerGameScreen: View {
    @Binding var path: [Routes]
    @State private var singlePlayerViewModel: SinglePlayerGameViewModel
    
    init(path: Binding<[Routes]>, category: TriviaCategory) {
        self._path = path
        self._singlePlayerViewModel = State(initialValue: SinglePlayerGameViewModel(
            playerName: "Player",
            category: category
        ))
    }
    
    var body: some View {
        ZStack {
            // Clean background
            GrayTheme.background
                .ignoresSafeArea()
            
            if singlePlayerViewModel.isLoading {
                // Loading state
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                    
                    Text("Loading question...")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.top)
                }
            } else if singlePlayerViewModel.gameEnded {
                // Game ended - navigate to results
                VStack {
                    Text("Game Complete!")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Button("View Results") {
                        path.append(Routes.singlePlayerResults(
                            finalScore: singlePlayerViewModel.getPlayerScore(),
                            questionsAnswered: singlePlayerViewModel.turns.count,
                            elapsedTime: singlePlayerViewModel.elapsedTime
                        ))
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(.green)
                    .cornerRadius(12)
                }
            } else {
                // Game content
                gameContentView
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await singlePlayerViewModel.startGame()
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
                            .overlay(
                                Capsule().stroke(GrayTheme.text.opacity(0.1), lineWidth: 1)
                            )
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
                
                // Question Text - with safety checks
                VStack(alignment: .leading, spacing: 12) {
                    let questionText = singlePlayerViewModel.currentQuestion.question
                    Text(questionText.isEmpty ? "Loading question..." : questionText)
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
                .shadow(color: .primary.opacity(0.08), radius: 12, x: 0, y: 6)
                .shadow(color: .primary.opacity(0.04), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 12)
                
                // Answer buttons right below question card - with safety checks
                if shouldShowAnswerButtons() {
                    answerButtonsView
                        .padding(.top, 20)
                }
                
                // Continue button - moved into main content area
                if shouldShowContinueButton() {
                    continueButtonView
                        .padding(.top, 30)
                }
                
                Spacer()
            }
            .padding(.horizontal, 0)
            .padding(.top, 60)
            .frame(maxHeight: .infinity)
        }
    }
    
    private func shouldShowAnswerButtons() -> Bool {
        return !singlePlayerViewModel.isLoading &&
               !singlePlayerViewModel.currentAnswerOptions.isEmpty &&
               !singlePlayerViewModel.currentAnswerOptions.contains("Loading...") &&
               !singlePlayerViewModel.currentQuestion.question.isEmpty &&
               singlePlayerViewModel.currentQuestion.question != "Loading..." &&
               singlePlayerViewModel.currentQuestion.question != "Loading question..."
    }
    
    private func shouldShowContinueButton() -> Bool {
        // Always show continue button when not loading and have valid question
        return shouldShowAnswerButtons()
    }
    
    private var continueButtonView: some View {
        Button {
            Task {
                // If no answer selected, this will skip the question
                // If answer selected but results not shown, this will reveal results  
                // If results shown, this will move to next question
                await singlePlayerViewModel.continueToNextQuestion()
            }
        } label: {
            Text(buttonText)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(GrayTheme.gold)
                )
                .shadow(color: GrayTheme.gold.opacity(0.35), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
    }
    
    private var buttonText: String {
        if singlePlayerViewModel.showResults {
            return singlePlayerViewModel.shouldEndGame ? "Finish Game" : "Next Question"
        } else if singlePlayerViewModel.selectedAnswer != nil {
            return "Show Answer"
        } else {
            return "Skip Question"
        }
    }
    
    private var answerButtonsView: some View {
        // Multiple choice answers - positioned right below question card
        VStack(spacing: 16) {
            ForEach(Array(singlePlayerViewModel.currentAnswerOptions.enumerated()), id: \.offset) { index, option in
                Button {
                    Task { @MainActor in
                        singlePlayerViewModel.selectAnswer(option)
                    }
                } label: {
                    HStack(spacing: 16) {
                        // Circle icon on the left - radio button style
                        ZStack {
                            Circle()
                                .stroke((singlePlayerViewModel.showResults && option == singlePlayerViewModel.currentQuestion.answer) ? Color.clear : Color.white, lineWidth: 2)
                                .frame(width: 24, height: 24)

                            if singlePlayerViewModel.selectedAnswer == option && !singlePlayerViewModel.showResults {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 12)
                            } else if singlePlayerViewModel.showResults && option == singlePlayerViewModel.currentQuestion.answer {
                                ZStack {
                                    Circle()
                                        .fill(GrayTheme.gold)
                                        .frame(width: 22, height: 22)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            } else if singlePlayerViewModel.showResults && option == singlePlayerViewModel.selectedAnswer && option != singlePlayerViewModel.currentQuestion.answer {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

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
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                Color.white,
                                lineWidth: (singlePlayerViewModel.selectedAnswer == option && !singlePlayerViewModel.showResults) ? 4 : 0
                            )
                    )
                    .scaleEffect(
                        (singlePlayerViewModel.selectedAnswer == option && !singlePlayerViewModel.showResults) ||
                        (singlePlayerViewModel.showResults && option == singlePlayerViewModel.currentQuestion.answer) ? 1.05 : 1.0
                    )
                    .animation(.easeInOut(duration: 0.2), value: singlePlayerViewModel.selectedAnswer)
                    .animation(.easeInOut(duration: 0.2), value: singlePlayerViewModel.showResults)
                    .opacity(singlePlayerViewModel.selectedAnswer == nil || singlePlayerViewModel.selectedAnswer == option || singlePlayerViewModel.showResults ? 1.0 : 0.6)
                }
                .disabled(singlePlayerViewModel.showResults)
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

