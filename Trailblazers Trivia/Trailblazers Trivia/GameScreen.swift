//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

struct GameScreen: View {
    @Binding var path: [Routes]
    @State private var gameViewModel = GameViewModel(player1Name: "Persians", player2Name: "Hebrews")
    
    var body: some View {
        ZStack {
            // Clean background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Player info above question
                    HStack(alignment: .center, spacing: 12) {
                        Text("\(gameViewModel.currentPlayer.name) \(gameViewModel.currentPlayerScore)/10")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Picker("Difficulty", selection: $gameViewModel.selectedDifficulty) {
                            Text("Easy").tag(Difficulty.easy)
                            Text("Hard").tag(Difficulty.hard)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 140)
                        .onChange(of: gameViewModel.selectedDifficulty) {
                            Task {
                                await gameViewModel.changeDifficultyForCurrentTurn(to: gameViewModel.selectedDifficulty)
                            }
                        }
                    }
                    Spacer()
                    // Question Text - larger and centered
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 12) {
                            if !gameViewModel.showAnswer {
                                // Category chip (question state)
                                Text("Bible History")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(Color.blue.opacity(0.25))
                                    )
                                // Question text
                                Text(gameViewModel.currentQuestion.question)
                                    .font(.largeTitle)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                            } else {
                                // Answer text (answer state)
                                Text(gameViewModel.currentQuestion.answer)
                                    .font(.system(size: 48, weight: .semibold))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .overlay(alignment: .bottomTrailing) {
                        if !gameViewModel.showAnswer {
                            Button {
                                gameViewModel.showAnswerToggle()
                            } label: {
                                Image(systemName: "eye.fill")
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(Color.blue.opacity(0.25))
                                    )
                            }
                            .padding(16)
                            .shadow(color: .primary.opacity(0.08), radius: 8, x: 0, y: 4)
                        } else {
                            Button {
                                gameViewModel.showAnswerToggle()
                            } label: {
                                Image(systemName: "arrow.left")
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(Color.blue.opacity(0.25))
                                    )
                            }
                            .padding(16)
                            .shadow(color: .primary.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                    }
                    .shadow(color: .primary.opacity(0.08), radius: 12, x: 0, y: 6)
                    .shadow(color: .primary.opacity(0.04), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(maxHeight: .infinity)
                
                // Removed the standalone Spacer() here
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onChange(of: gameViewModel.gameEnded) { _, gameEnded in
            if gameEnded {
                let playerScores = gameViewModel.getAllPlayerScores()
                path.append(Routes.results(playerScores: playerScores))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: Routes.results(
                    playerScores: gameViewModel.getAllPlayerScores()
                )) {
                    Text("End")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                if true {
                    HStack(spacing: 16) {
                        Button {
                            gameViewModel.answeredCorrect()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.headline)
                                Text("Correct")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .shadow(color: .green.opacity(0.25), radius: 8, x: 0, y: 4)
                        }
                        
                        Button {
                            gameViewModel.answeredWrong()
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.headline)
                                Text("Wrong")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .shadow(color: .red.opacity(0.25), radius: 8, x: 0, y: 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    GameScreen(path: .constant([]))
}
