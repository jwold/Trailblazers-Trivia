//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

private extension Color {
    static let appBackground = Color(red: 0.06, green: 0.07, blue: 0.09) // #0F1218 approx
    static let cardBackground = Color(red: 0.14, green: 0.16, blue: 0.20) // #242833 approx
    static let chipBlue = Color(red: 0.35, green: 0.55, blue: 0.85) // #5A8CD8 approx
    static let coral = Color(red: 1.0, green: 0.50, blue: 0.44) // #FF7F70 approx
    static let controlTrack = Color(red: 0.18, green: 0.20, blue: 0.24)
    static let controlShadow = Color.black.opacity(0.5)
    static let labelPrimary = Color(red: 0.75, green: 0.77, blue: 0.83) // #BEC3D4
}

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
                    HStack(alignment: .center, spacing: 12) {
                        Button {
                            path = []
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundColor(Color.labelPrimary.opacity(0.7))
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 12).fill(Color.controlTrack)
                                )
                        }
                        
                        // Connected team boxes spanning the width
                        HStack(spacing: 0) {
                            // Player 1 box
                            VStack(spacing: 6) {
                                Text(gameViewModel.player1.name)
                                    .font(.headline)
                                    .fontWeight(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? .bold : .medium)
                                    .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? Color.chipBlue : Color.labelPrimary.opacity(0.7))
                                
                                Text(String(format: "%.1f/10 pts", gameViewModel.getPlayerScore(for: gameViewModel.player1)))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.labelPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 20,
                                    bottomLeadingRadius: 20,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: 0
                                )
                                .fill(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? Color.controlTrack.opacity(0.8) : Color.controlTrack.opacity(0.4))
                            )
                            
                            // Player 2 box
                            VStack(spacing: 6) {
                                Text(gameViewModel.player2.name)
                                    .font(.headline)
                                    .fontWeight(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? .bold : .medium)
                                    .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? Color.chipBlue : Color.labelPrimary.opacity(0.7))
                                
                                Text(String(format: "%.1f/10 pts", gameViewModel.getPlayerScore(for: gameViewModel.player2)))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.labelPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 20,
                                    topTrailingRadius: 20
                                )
                                .fill(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? Color.controlTrack.opacity(0.8) : Color.controlTrack.opacity(0.4))
                            )
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
                                    .foregroundColor(.black.opacity(0.85))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(Color.chipBlue)
                                    )
                                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
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
                                // Answer state with category chip
                                VStack(alignment: .leading, spacing: 12) {
                                    // Category chip (also shown in answer state)
                                    Text("Bible History")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black.opacity(0.85))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule().fill(Color.chipBlue)
                                        )
                                        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                                    
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
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
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
                if true {
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
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .background(Color.appBackground)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: -2)
        }
    }
}

#Preview {
    GameScreen(path: .constant([]))
}

