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
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Player info above question
                    HStack(alignment: .center, spacing: 0) {
                        // Connected team boxes - aligned with question card
                        HStack(spacing: 0) {
                            // Player 1 section
                            HStack(spacing: 8) {
                                Text(gameViewModel.player1.name)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? .black.opacity(0.9) : Color.labelPrimary.opacity(0.8))
                                    .lineLimit(1)
                                
                                Text(ScoreFormatter.format(gameViewModel.getPlayerScore(for: gameViewModel.player1)))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? .black.opacity(0.9) : Color.labelPrimary.opacity(0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? .white : Color.clear)
                            )
                            
                            // Player 2 section
                            HStack(spacing: 8) {
                                Text(gameViewModel.player2.name)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? .black.opacity(0.9) : Color.labelPrimary.opacity(0.8))
                                    .lineLimit(1)
                                
                                Text(ScoreFormatter.format(gameViewModel.getPlayerScore(for: gameViewModel.player2)))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? .black.opacity(0.9) : Color.labelPrimary.opacity(0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? Color.chipBlue : Color.clear)
                            )
                        }
                        .padding(.leading, 12) // Align with question card
                        .padding(.trailing, 12) // Match left padding
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.controlTrack.opacity(0.6))
                                .stroke(Color.labelPrimary.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
                        .frame(maxWidth: 280) // Limit the width of the score boxes
                        .padding(.bottom, 8) // Add small bottom padding to score boxes
                        
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
                        .padding(.trailing, 12) // Align with question card
                    }
                    Spacer()
                    // Question Text - larger and centered
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 12) {
                            if !gameViewModel.showAnswer {
                                // Question text
                                Text(gameViewModel.currentQuestion.question)
                                    .font(.system(size: 34, weight: .medium))
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(maxHeight: .infinity, alignment: .topLeading)
                                    .foregroundColor(Color.labelPrimary)
                            } else {
                                // Answer state
                                VStack(alignment: .leading, spacing: 12) {
                                    // Answer text
                                    Text(gameViewModel.currentQuestion.answer)
                                        .font(.system(size: 50, weight: .semibold))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .foregroundColor(Color.labelPrimary)
                                }
                            }
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
                    .overlay(alignment: .bottomTrailing) {
                        if !gameViewModel.showAnswer {
                            Button {
                                gameViewModel.showAnswerToggle()
                            } label: {
                                Image(systemName: "eye.fill")
                                    .font(.title3)
                                    .foregroundColor(.black.opacity(0.85))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(Color.chipBlue)
                                    )
                                    .shadow(color: Color.chipBlue.opacity(0.35), radius: 16, x: 0, y: 8)
                            }
                            .padding(16)
                            .shadow(color: .primary.opacity(0.08), radius: 8, x: 0, y: 4)
                        } else {
                            Button {
                                gameViewModel.showAnswerToggle()
                            } label: {
                                Image(systemName: "arrow.left")
                                    .font(.title3)
                                    .foregroundColor(.black.opacity(0.85))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(Color.chipBlue)
                                    )
                                    .shadow(color: Color.chipBlue.opacity(0.35), radius: 16, x: 0, y: 8)
                            }
                            .padding(16)
                            .shadow(color: .primary.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 12) // Add padding back for question card
                    Spacer()
                }
                .padding(.horizontal, 0) // Remove horizontal padding to allow score box to go to edge
                .padding(.top, 60)
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
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                        Button {
                            gameViewModel.answeredWrong()
                        } label: {
                            Text("Wrong")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.coral, Color.coral.opacity(0.9)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: Color.coral.opacity(0.25), radius: 8, x: 0, y: 4)
                        
                        Button {
                            gameViewModel.answeredCorrect()
                        } label: {
                            Text("Correct")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.chipBlue, Color.chipBlue.opacity(0.9)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: Color.chipBlue.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(.horizontal, 12) // Reduced from 20 to 12
            .padding(.bottom, 40)
            .background(Color.appBackground)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: -2)
        }
    }

#Preview {
    GameScreen(path: .constant([]))
}

