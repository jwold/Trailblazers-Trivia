//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI
import Combine

struct GameView: View {
    @StateObject private var gameState = GameState()
    @Environment(\.dismiss) private var dismiss
    
    let selectedCategory: TriviaGameCategory
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Player Header
                    VStack(spacing: 15) {
                        Text(gameState.currentPlayer)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(gameState.currentScore)/\(gameState.totalPossiblePoints) points")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        // Difficulty Toggle
                        HStack(spacing: 20) {
                            Button("Easy") {
                                gameState.selectedDifficulty = .easy
                                gameState.startGame(with: selectedCategory, difficulty: .easy)
                            }
                            .foregroundColor(gameState.selectedDifficulty == .easy ? .white : .blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(gameState.selectedDifficulty == .easy ? Color.blue : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            Button("Hard") {
                                gameState.selectedDifficulty = .hard
                                gameState.startGame(with: selectedCategory, difficulty: .hard)
                            }
                            .foregroundColor(gameState.selectedDifficulty == .hard ? .white : .blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(gameState.selectedDifficulty == .hard ? Color.blue : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Question Section
                    if let question = gameState.currentQuestion {
                        VStack(spacing: 30) {
                            // Question Card
                            VStack(spacing: 20) {
                                Text(question.question)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                if !gameState.showAnswer {
                                    Button("Show answer") {
                                        gameState.showAnswerToggle()
                                    }
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                } else {
                                    VStack(spacing: 10) {
                                        Text(question.answer)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        if !question.reference.isEmpty {
                                            Text(question.reference)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.vertical, 30)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.regularMaterial)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal, 20)
                            
                            // Action Buttons (only show when answer is revealed)
                            if gameState.showAnswer {
                                VStack(spacing: 15) {
                                    HStack(spacing: 15) {
                                        Button("Correct") {
                                            gameState.answerCorrect()
                                        }
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        Button("Wrong") {
                                            gameState.answerWrong()
                                        }
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.gray)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    
                                    Button("Skip Question") {
                                        gameState.skipQuestion()
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    } else if gameState.gameEnded {
                        VStack(spacing: 20) {
                            Text("Game Complete!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Final Score: \(gameState.currentScore)/\(gameState.totalPossiblePoints)")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Button("Start New Game") {
                                gameState.startGame(with: selectedCategory, difficulty: gameState.selectedDifficulty)
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.regularMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Image(systemName: "house.circle.fill")
                        .font(.title2)
                    Text("Trailblazers Trivia")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Game") {
                    dismiss()
                }
                .foregroundColor(.red)
            }
        }
        .onAppear {
            gameState.startGame(with: selectedCategory, difficulty: .easy)
        }
    }
}

#Preview {
    GameView(selectedCategory: .bible)
}
