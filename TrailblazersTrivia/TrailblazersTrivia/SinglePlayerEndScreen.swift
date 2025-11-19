//
//  SinglePlayerEndScreen.swift
//  TrailblazersTrivia
//
//  Created by AI Assistant on 10/17/25.
//

import SwiftUI

struct SinglePlayerEndScreen: View {
    @Binding var path: [Routes]
    let finalScore: Double
    let questionsAnswered: Int
    let elapsedTime: TimeInterval
    
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
            return "You reached 10 points in \(formatTime(elapsedTime))!"
        } else {
            return "You answered \(questionsAnswered) questions in \(formatTime(elapsedTime))"
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
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
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(gameCompletionDescription)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
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
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(ScoreFormatter.format(finalScore))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("out of 10 points")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    // Progress indicator
                    VStack(spacing: 12) {
                        HStack {
                            Text("Progress")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text("\(Int((finalScore / 10.0) * 100))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
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
                                .foregroundColor(.white)
                            
                            Text("Questions")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        VStack(spacing: 4) {
                            let correctCount = Int(finalScore + 0.5) // Approximate correct answers
                            Text("\(correctCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.correctGreen)
                            
                            Text("Correct")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        VStack(spacing: 4) {
                            let wrongCount = questionsAnswered - Int(finalScore + 0.5)
                            Text("\(max(0, wrongCount))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.coral)
                            
                            Text("Wrong")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        VStack(spacing: 4) {
                            Text(formatTime(elapsedTime))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.chipBlue)
                            
                            Text("Time")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
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
                .buttonStyle(PlainButtonStyle())
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
