//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

struct GameScreen: View {
    @Binding var path: [Routes]
    @State private var gameViewModel = GameViewModel(player1Name: "Persian", player2Name: "Player 2")
    
    var body: some View {
        ZStack {
            // Clean background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Difficulty Segmented Control - Stocks app style
                VStack(spacing: 16) {
                    Picker("Difficulty", selection: $gameViewModel.selectedDifficulty) {
                        Text("Easy").tag(Difficulty.easy)
                        Text("Hard").tag(Difficulty.hard)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    .onChange(of: gameViewModel.selectedDifficulty) {
                        gameViewModel.changeDifficultyForCurrentTurn(to: gameViewModel.selectedDifficulty)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Player info above question
                    HStack {
                        Spacer()
                        Text("\(gameViewModel.currentPlayer.name)'s Turn • \(gameViewModel.currentPlayerScore) Points")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Question Text - larger and centered
                    HStack {
                        Spacer()
                        Text(gameViewModel.currentQuestion.question)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Answer Display (when shown)
                    if gameViewModel.showAnswer {
                        VStack(spacing: 16) {
                            Text(gameViewModel.currentQuestion.answer)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
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
                        .shadow(color: .primary.opacity(0.08), radius: 12, x: 0, y: 6)
                        .shadow(color: .primary.opacity(0.04), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Bottom Buttons Section
                VStack(spacing: 16) {
                    if !gameViewModel.showAnswer {
                        Button {
                            gameViewModel.showAnswerToggle()
                        } label: {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .font(.headline)
                                Text("Show Answer")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .shadow(color: .blue.opacity(0.25), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Action Buttons
                        VStack(spacing: 16) {
                            Button {
                                gameViewModel.answerCorrect()
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
                                gameViewModel.answerWrong()
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
                            
                            Button {
                                gameViewModel.showAnswerToggle()
                            } label: {
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .font(.subheadline)
                                    Text("Hide Answer")
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .strokeBorder(.quaternary, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    path.removeLast()
                }
                .foregroundColor(.blue)
                .font(.headline)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: Routes.results) {
                    Text("End")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    GameScreen(path: .constant([]))
}
