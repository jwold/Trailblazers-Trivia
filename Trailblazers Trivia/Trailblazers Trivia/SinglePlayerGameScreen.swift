//
//  SinglePlayerGameScreen.swift
//  Trailblazers Trivia
//
//  Created by AI Assistant on 10/17/25.
//

import SwiftUI

private extension Color {
    static let appBackground = Color(red: 0.06, green: 0.07, blue: 0.09) // #0F1218 approx
    static let cardBackground = Color(red: 0.18, green: 0.20, blue: 0.24) // Slightly lighter gray
    static let lightCardBackground = Color(red: 0.25, green: 0.28, blue: 0.32) // Even lighter gray for chips
    static let chipBlue = Color(red: 0.35, green: 0.55, blue: 0.85) // #5A8CD8 approx
    static let coral = Color(red: 1.0, green: 0.50, blue: 0.44) // #FF7F70 approx
    static let correctGreen = Color(red: 0.4, green: 0.8, blue: 0.4) // Green for correct answers
    static let controlTrack = Color(red: 0.18, green: 0.20, blue: 0.24)
    static let labelPrimary = Color(red: 0.75, green: 0.77, blue: 0.83) // #BEC3D4
}

struct SinglePlayerGameScreen: View {
    @Binding var path: [Routes]
    @State private var singlePlayerViewModel = SinglePlayerGameViewModel(playerName: "Player")
    
    // Function to format scores - show decimal only for .5, hide for .0
    private func formatScore(_ score: Double) -> String {
        let wholeNumber = Int(score)
        let remainder = score - Double(wholeNumber)
        
        if remainder == 0.5 {
            return String(format: "%.1f", score)
        } else if remainder == 0 {
            return "\(wholeNumber)"
        } else {
            // For any other fractional values, show one decimal place
            return String(format: "%.1f", score)
        }
    }
    
    var body: some View {
        ZStack {
            // Clean background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Player info above question
                    HStack(alignment: .center, spacing: 0) {
                        // Single player score box - matching two-player style
                        HStack(spacing: 0) {
                            HStack(spacing: 8) {
                                Text("\(formatScore(singlePlayerViewModel.getPlayerScore()))/10 Points • \(singlePlayerViewModel.formatElapsedTime())")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.labelPrimary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.lightCardBackground)
                            )
                        }
                        .padding(.leading, 12)
                        .padding(.trailing, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.controlTrack.opacity(0.6))
                                .stroke(Color.labelPrimary.opacity(0.1), lineWidth: 1)
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
                                    Circle().fill(Color.labelPrimary.opacity(0.15))
                                )
                        }
                        .padding(.trailing, 12)
                    }
                    
                    Spacer()
                    
                    // Question Text - larger and centered (no eyeball button)
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Category chip
                            Text("Bible History")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.labelPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(Color.lightCardBackground)
                                )
                            
                            // Question text
                            Text(singlePlayerViewModel.currentQuestion.question)
                                .font(.system(size: 34, weight: .medium))
                                .fontWeight(.medium)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(maxHeight: .infinity, alignment: .topLeading)
                                .foregroundColor(Color.labelPrimary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 24))
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
                    .overlay(alignment: .topTrailing) {
                        if singlePlayerViewModel.hasAnswered {
                            let isCorrect = singlePlayerViewModel.selectedAnswer == singlePlayerViewModel.currentQuestion.answer
                            
                            Text(isCorrect ? "Correct" : "Wrong")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(isCorrect ? .white : .black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(isCorrect ? Color.correctGreen : Color.coral)
                                )
                                .padding(16)
                        }
                    }
                    .padding(.horizontal, 12)
                    
                    Spacer()
                }
                .padding(.horizontal, 0)
                .padding(.top, 60)
                .frame(maxHeight: .infinity)
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
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                // Multiple choice answers
                VStack(spacing: 12) {
                    ForEach(singlePlayerViewModel.currentAnswerOptions, id: \.self) { option in
                        Button {
                            singlePlayerViewModel.selectAnswer(option)
                        } label: {
                            HStack {
                                Text(option)
                                    .fontWeight(.semibold)
                                    .font(.headline)
                                    .foregroundColor(.black.opacity(0.9))
                                
                                Spacer()
                                
                                if singlePlayerViewModel.hasAnswered {
                                    if option == singlePlayerViewModel.currentQuestion.answer {
                                        // Correct answer - white checkmark
                                        Image(systemName: "checkmark")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    } else if option == singlePlayerViewModel.selectedAnswer {
                                        // Wrong selected answer - black X
                                        Image(systemName: "xmark")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(buttonColor(for: option))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .disabled(singlePlayerViewModel.hasAnswered)
                        .shadow(color: buttonColor(for: option).opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                }
                
                // Continue button
                Button {
                    Task {
                        await singlePlayerViewModel.continueToNextQuestion()
                    }
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .font(.headline)
                        .foregroundColor(.black.opacity(singlePlayerViewModel.hasAnswered ? 0.9 : 0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(singlePlayerViewModel.hasAnswered ? Color.white : Color.chipBlue.opacity(0.3))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(singlePlayerViewModel.hasAnswered ? 0.1 : 0.05), lineWidth: 1)
                        )
                }
                .disabled(!singlePlayerViewModel.hasAnswered)
                .shadow(color: Color.white.opacity(singlePlayerViewModel.hasAnswered ? 0.25 : 0.1), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 40)
            .background(Color.appBackground)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: -2)
        }
    }
    
    private func buttonColor(for option: String) -> Color {
        if !singlePlayerViewModel.hasAnswered {
            return Color.chipBlue
        }
        
        if option == singlePlayerViewModel.currentQuestion.answer {
            return Color.correctGreen
        } else if option == singlePlayerViewModel.selectedAnswer {
            return Color.coral
        } else {
            return Color.chipBlue.opacity(0.5)
        }
    }
}

#Preview {
    SinglePlayerGameScreen(path: .constant([]))
}