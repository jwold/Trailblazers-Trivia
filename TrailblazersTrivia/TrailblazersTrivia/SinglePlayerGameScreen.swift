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
    static let gold = Color(red: 0.35, green: 0.55, blue: 0.77) // #5A8BC4 blue
}

struct SinglePlayerGameScreen: View {
    @Binding var path: [Routes]
    @State private var singlePlayerViewModel: SinglePlayerGameViewModel
    @State private var showInfoModal = false
    
    init(path: Binding<[Routes]>, category: TriviaCategory) {
        self._path = path
        self._singlePlayerViewModel = State(initialValue: SinglePlayerGameViewModel(
            playerName: "Player",
            category: category,
            questionRepository: JSONQuestionRepository()
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
        .sheet(isPresented: $showInfoModal) {
            SinglePlayerInfoModalView()
        }
        .onAppear {
            singlePlayerViewModel.startGame()
        }
    }

    
    private var gameContentView: some View {
        VStack(spacing: 0) {
            // Content Section
            VStack(alignment: .leading, spacing: 20) {
                // Player info above question
                HStack(alignment: .center, spacing: 12) {
                    // Back button
                    Button {
                        path = []
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(GrayTheme.text)
                            .frame(width: 44, height: 44)
                    }
                    
                    // Single player score box - next to back button
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            TickerTapeScore(
                                score: singlePlayerViewModel.getPlayerScore(),
                                font: .subheadline,
                                fontWeight: .semibold,
                                foregroundColor: GrayTheme.text
                            )
                            Text("/10 Points • \(singlePlayerViewModel.formatElapsedTime())")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(GrayTheme.text)
                                .lineLimit(1)
                        }
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
                }
                .padding(.horizontal, 24)
                
                // Question Text - with safety checks
                VStack(alignment: .leading, spacing: 12) {
                    let questionText = singlePlayerViewModel.currentQuestion.question
                    Text(questionText.isEmpty ? "Loading question..." : questionText)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(GrayTheme.text)
                        .id(singlePlayerViewModel.currentQuestion.id) // Force view update on question change
                        .transition(.opacity) // Fade transition
                        .animation(.easeInOut(duration: 0.3), value: singlePlayerViewModel.currentQuestion.id)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                
                // Answer buttons right below question card - with safety checks
                if shouldShowAnswerButtons() {
                    answerButtonsView
                        .padding(.top, 20)
                        .transition(.opacity) // Fade transition
                        .animation(.easeInOut(duration: 0.3), value: singlePlayerViewModel.currentQuestion.id)
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
        // Only show continue button when an answer has been selected
        return shouldShowAnswerButtons() && singlePlayerViewModel.selectedAnswer != nil
    }
    
    private var continueButtonView: some View {
        Button {
            // If answer selected but results not shown, this will reveal results  
            // If results shown, this will move to next question
            singlePlayerViewModel.continueToNextQuestion()
        } label: {
            Text(buttonText)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(isButtonEnabled ? 0.9 : 0.4))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isButtonEnabled ? GrayTheme.gold : Color.gray.opacity(0.3))
                )
                .shadow(color: isButtonEnabled ? GrayTheme.gold.opacity(0.35) : Color.clear, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isButtonEnabled)
        .padding(.horizontal, 24)
    }
    
    private var isButtonEnabled: Bool {
        // Button is enabled when an answer is selected
        singlePlayerViewModel.selectedAnswer != nil
    }
    
    private var buttonText: String {
        if singlePlayerViewModel.showResults {
            return singlePlayerViewModel.shouldEndGame ? "Finish Game" : "Next Question"
        } else if singlePlayerViewModel.selectedAnswer != nil {
            return "Show Answer"
        } else {
            return "Select an Answer"
        }
    }
    
    private var answerButtonsView: some View {
        // Multiple choice answers - positioned right below question card
        VStack(spacing: 16) {
            ForEach(Array(singlePlayerViewModel.currentAnswerOptions.enumerated()), id: \.offset) { index, option in
                Button {
                    singlePlayerViewModel.selectAnswer(option)
                } label: {
                    HStack(spacing: 16) {
                        // Answer text with strikethrough for wrong answers
                        Text(option)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(answerTextColor(for: option))
                            .strikethrough(shouldStrikethrough(option), color: .white.opacity(0.5))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Show checkmark or X only after results are revealed
                        if singlePlayerViewModel.showResults {
                            if option == singlePlayerViewModel.currentQuestion.answer {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            } else if option == singlePlayerViewModel.selectedAnswer {
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
                .disabled(singlePlayerViewModel.showResults)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Answer Button Styling Helpers
    
    private func answerTextColor(for option: String) -> Color {
        if singlePlayerViewModel.showResults {
            if option == singlePlayerViewModel.currentQuestion.answer {
                return .white // Correct answer stays white
            } else if option == singlePlayerViewModel.selectedAnswer {
                return .white.opacity(0.5) // Wrong selected answer is dimmed
            } else {
                return .white.opacity(0.4) // Other wrong answers are dimmed
            }
        }
        return .white
    }
    
    private func shouldStrikethrough(_ option: String) -> Bool {
        // Strike through the selected wrong answer
        return singlePlayerViewModel.showResults && 
               option == singlePlayerViewModel.selectedAnswer && 
               option != singlePlayerViewModel.currentQuestion.answer
    }
    
    private func buttonBorderColor(for option: String) -> Color {
        if singlePlayerViewModel.showResults && option == singlePlayerViewModel.currentQuestion.answer {
            return .white
        } else if singlePlayerViewModel.selectedAnswer == option && !singlePlayerViewModel.showResults {
            return .white
        }
        return GrayTheme.text.opacity(0.2)
    }
    
    private func buttonBorderWidth(for option: String) -> CGFloat {
        if singlePlayerViewModel.showResults && option == singlePlayerViewModel.currentQuestion.answer {
            return 3
        } else if singlePlayerViewModel.selectedAnswer == option && !singlePlayerViewModel.showResults {
            return 2
        }
        return 1
    }
    

    private func buttonOpacity(for option: String) -> Double {
        if singlePlayerViewModel.showResults {
            // Correct answer is always visible
            if option == singlePlayerViewModel.currentQuestion.answer {
                return 1.0
            }
            // Wrong answers are dimmed
            return 0.6
        }
        // Before showing results, show selected or all options
        return singlePlayerViewModel.selectedAnswer == nil || singlePlayerViewModel.selectedAnswer == option ? 1.0 : 0.6
    }
}

// MARK: - Single Player Info Modal View (Wrapper for UnifiedInfoModalView)

struct SinglePlayerInfoModalView: View {
    var body: some View {
        UnifiedInfoModalView()
    }
}

#Preview {
    SinglePlayerGameScreen(path: .constant([]), category: .bible)
}

