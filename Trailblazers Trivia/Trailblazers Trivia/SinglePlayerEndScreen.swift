//
//  SinglePlayerEndScreen.swift
//  Trailblazers Trivia
//
//  Created by AI Assistant on 10/17/25.
//

import SwiftUI

private extension Color {
    static let appBackground = Color(red: 0.06, green: 0.07, blue: 0.09)
    static let cardBackground = Color(red: 0.18, green: 0.20, blue: 0.24)
    static let lightCardBackground = Color(red: 0.25, green: 0.28, blue: 0.32)
    static let chipBlue = Color(red: 0.35, green: 0.55, blue: 0.85)
    static let coral = Color(red: 1.0, green: 0.50, blue: 0.44)
    static let correctGreen = Color(red: 0.4, green: 0.8, blue: 0.4)
    static let controlTrack = Color(red: 0.18, green: 0.20, blue: 0.24)
    static let labelPrimary = Color(red: 0.75, green: 0.77, blue: 0.83)
}

struct SinglePlayerEndScreen: View {
    @Binding var path: [Routes]
    let finalScore: Double
    let questionsAnswered: Int
    let elapsedTime: TimeInterval
    
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
    
    // Format elapsed time as MM:SS
    private func formatElapsedTime() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var gameCompletionMessage: String {
        if finalScore >= 10 {
            return "Congratulations!"
        } else if finalScore >= 7 {
            return "Great Job!"
        } else if finalScore >= 5 {
            return "Good Effort!"
        } else {
            return "Keep Practicing!"
        }
    }
    
    private var gameCompletionDescription: String {
        if finalScore >= 10 {
            return "You reached 10 points in \(formatElapsedTime())!"
        } else {
            return "You answered \(questionsAnswered) questions in \(formatElapsedTime())"
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .center, spacing: 20) {
                    // Game completion message
                    Text(gameCompletionMessage)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.labelPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(gameCompletionDescription)
                        .font(.title3)
                        .foregroundColor(Color.labelPrimary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)

                // Score card
                VStack(alignment: .center, spacing: 24) {
                    // Large score display
                    VStack(spacing: 8) {
                        Text("Final Score")
                            .font(.headline)
                            .foregroundColor(Color.labelPrimary.opacity(0.8))
                        
                        Text(formatScore(finalScore))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(Color.labelPrimary)
                        
                        Text("out of 10 points")
                            .font(.subheadline)
                            .foregroundColor(Color.labelPrimary.opacity(0.6))
                    }
                    
                    // Progress indicator
                    VStack(spacing: 12) {
                        HStack {
                            Text("Progress")
                                .font(.subheadline)
                                .foregroundColor(Color.labelPrimary.opacity(0.8))
                            
                            Spacer()
                            
                            Text("\(Int((finalScore / 10.0) * 100))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.labelPrimary)
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background bar
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.controlTrack.opacity(0.6))
                                    .frame(height: 12)
                                
                                // Progress bar
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.chipBlue)
                                    .frame(width: geometry.size.width * CGFloat(finalScore / 10.0), height: 12)
                                    .animation(.easeInOut(duration: 1.0), value: finalScore)
                            }
                        }
                        .frame(height: 12)
                    }
                    
                    // Additional stats
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("\(questionsAnswered)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.labelPrimary)
                            
                            Text("Questions")
                                .font(.caption)
                                .foregroundColor(Color.labelPrimary.opacity(0.6))
                        }
                        
                        VStack(spacing: 4) {
                            let correctCount = Int(finalScore + 0.5) // Approximate correct answers
                            Text("\(correctCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.correctGreen)
                            
                            Text("Correct")
                                .font(.caption)
                                .foregroundColor(Color.labelPrimary.opacity(0.6))
                        }
                        
                        VStack(spacing: 4) {
                            let wrongCount = questionsAnswered - Int(finalScore + 0.5)
                            Text("\(max(0, wrongCount))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.coral)
                            
                            Text("Wrong")
                                .font(.caption)
                                .foregroundColor(Color.labelPrimary.opacity(0.6))
                        }
                        
                        VStack(spacing: 4) {
                            Text(formatElapsedTime())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.chipBlue)
                            
                            Text("Time")
                                .font(.caption)
                                .foregroundColor(Color.labelPrimary.opacity(0.6))
                        }
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity)
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
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 20)
                .padding(.top, 40)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                Button(action: {
                    path.removeLast(path.count)
                }) {
                    Text("Play Again")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.white.opacity(0.25), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .background(Color.appBackground)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: -2)
        }
    }
}

#Preview {
    SinglePlayerEndScreen(
        path: .constant([]), 
        finalScore: 7.5,
        questionsAnswered: 12,
        elapsedTime: 183.5 // 3 minutes and 3.5 seconds
    )
}