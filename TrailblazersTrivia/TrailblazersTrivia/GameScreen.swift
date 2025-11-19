//
//  GameView.swift
//  TrailblazersTrivia
//
//  Created by Joshua Wold on 9/16/25.
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

struct GameScreen: View {
    @Binding var path: [Routes]
    let category: TriviaCategory
    @State private var gameViewModel: GameViewModel
    @State private var showInfoModal = false
    
    init(path: Binding<[Routes]>, category: TriviaCategory) {
        self._path = path
        self.category = category
        
        // Generate team names based on category
        let teamNames = TeamNameGenerator.generateTeamNames(for: category)
        self._gameViewModel = State(initialValue: GameViewModel(
            player1Name: teamNames.team1, 
            player2Name: teamNames.team2,
            category: category,
            questionRepository: JSONQuestionRepository()
        ))
    }
    
    var body: some View {
        ZStack {
            // Clean background
            GrayTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Player info above question
                    HStack(alignment: .center, spacing: 0) {
                        // Back button
                        Button {
                            path = []
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(GrayTheme.text)
                                .frame(width: 44, height: 44)
                        }
                        .padding(.leading, 12)
                        
                        Spacer()
                        
                        // Connected team boxes - aligned with question card
                        HStack(spacing: 0) {
                            // Player 1 section
                            HStack(spacing: 8) {
                                Text(gameViewModel.player1.name)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? .black.opacity(0.9) : GrayTheme.text.opacity(0.8))
                                    .lineLimit(1)
                                
                                TickerTapeScore(
                                    score: gameViewModel.getPlayerScore(for: gameViewModel.player1),
                                    font: .system(size: 16, weight: .bold, design: .rounded),
                                    fontWeight: .bold,
                                    foregroundColor: gameViewModel.currentPlayer.name == gameViewModel.player1.name ? .black.opacity(0.9) : GrayTheme.text.opacity(0.8)
                                )
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? GrayTheme.gold : Color.clear)
                            )
                            
                            // Player 2 section
                            HStack(spacing: 8) {
                                Text(gameViewModel.player2.name)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? .black.opacity(0.9) : GrayTheme.text.opacity(0.8))
                                    .lineLimit(1)
                                
                                TickerTapeScore(
                                    score: gameViewModel.getPlayerScore(for: gameViewModel.player2),
                                    font: .system(size: 16, weight: .bold, design: .rounded),
                                    fontWeight: .bold,
                                    foregroundColor: gameViewModel.currentPlayer.name == gameViewModel.player2.name ? .black.opacity(0.9) : GrayTheme.text.opacity(0.8)
                                )
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? GrayTheme.gold : Color.clear)
                            )
                        }
                        .frame(maxWidth: 280) // Limit the width of the score boxes
                        
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
                        .padding(.trailing, 12)
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
                                    .foregroundColor(GrayTheme.text)
                            } else {
                                // Answer state
                                VStack(alignment: .leading, spacing: 12) {
                                    // Answer text
                                    Text(gameViewModel.currentQuestion.answer)
                                        .font(.system(size: 50, weight: .semibold))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .foregroundColor(GrayTheme.text)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .center)
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
                                        Circle().fill(GrayTheme.gold)
                                    )
                                    .shadow(color: GrayTheme.gold.opacity(0.35), radius: 16, x: 0, y: 8)
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
                                        Circle().fill(GrayTheme.gold)
                                    )
                                    .shadow(color: GrayTheme.gold.opacity(0.35), radius: 16, x: 0, y: 8)
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
        .sheet(isPresented: $showInfoModal) {
            InfoModalView()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                        Button {
                            gameViewModel.answeredWrong()
                        } label: {
                            Text("Wrong")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(GrayTheme.accent)
                                )
                                .shadow(color: GrayTheme.accent.opacity(0.25), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            gameViewModel.answeredCorrect()
                        } label: {
                            Text("Correct")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(GrayTheme.gold)
                                )
                                .shadow(color: GrayTheme.gold.opacity(0.25), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 12) // Reduced from 20 to 12
            .padding(.bottom, 40)
            .background(GrayTheme.background)
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: -2)
        }
    }

// MARK: - Info Modal View

struct InfoModalView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            GrayTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Spacer()
                    Text("How to Play")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(GrayTheme.text)
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(GrayTheme.text.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(GrayTheme.card)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "megaphone.fill")
                                .font(.title2)
                                .foregroundColor(GrayTheme.gold)
                            Text("Shout Out Mode")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(GrayTheme.text)
                        }
                        
                        Text("This mode is intended for a group setting, with two teams. The person reading the question can choose to be on a team, since the answer is hidden.")
                            .font(.body)
                            .foregroundColor(GrayTheme.text.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(GrayTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [GrayTheme.text.opacity(0.12), GrayTheme.text.opacity(0.04)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    
                    // Instructions list
                    VStack(alignment: .leading, spacing: 16) {
                        InstructionRow(number: "1", text: "Read the question out loud to both teams")
                        InstructionRow(number: "2", text: "First team to shout out the correct answer gets the point")
                        InstructionRow(number: "3", text: "Tap 'Show Answer' to reveal the correct answer")
                        InstructionRow(number: "4", text: "Award points using 'Correct' or 'Wrong' buttons")
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Close button
                Button {
                    dismiss()
                } label: {
                    Text("Got it!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(GrayTheme.gold)
                        )
                        .shadow(color: GrayTheme.gold.opacity(0.35), radius: 10, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Instruction Row

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black.opacity(0.9))
                .frame(width: 32, height: 32)
                .background(
                    Circle().fill(GrayTheme.gold)
                )
            
            Text(text)
                .font(.body)
                .foregroundColor(GrayTheme.text.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    GameScreen(path: .constant([]), category: .bible)
}

