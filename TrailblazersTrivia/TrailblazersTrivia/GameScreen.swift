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
    @State private var showEditTeam1 = false
    @State private var showEditTeam2 = false
    @State private var editingTeam1Name = ""
    @State private var editingTeam2Name = ""
    
    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    
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
                            impactLight.impactOccurred()
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
                            VStack(spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(gameViewModel.player1.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(GrayTheme.text)
                                    
                                    TickerTapeScore(
                                        score: gameViewModel.getPlayerScore(for: gameViewModel.player1),
                                        font: .subheadline,
                                        fontWeight: .bold,
                                        foregroundColor: GrayTheme.text
                                    )
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(GrayTheme.card)
                                    )
                                }
                                
                                Rectangle()
                                    .fill(gameViewModel.currentPlayer.name == gameViewModel.player1.name ? GrayTheme.gold : Color.clear)
                                    .frame(height: 3)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .onTapGesture {
                                impactLight.impactOccurred()
                                editingTeam1Name = gameViewModel.player1.name
                                showEditTeam1 = true
                            }
                            
                            // Player 2 section
                            VStack(spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(gameViewModel.player2.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(GrayTheme.text)
                                    
                                    TickerTapeScore(
                                        score: gameViewModel.getPlayerScore(for: gameViewModel.player2),
                                        font: .subheadline,
                                        fontWeight: .bold,
                                        foregroundColor: GrayTheme.text
                                    )
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(GrayTheme.card)
                                    )
                                }
                                
                                Rectangle()
                                    .fill(gameViewModel.currentPlayer.name == gameViewModel.player2.name ? GrayTheme.gold : Color.clear)
                                    .frame(height: 3)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .onTapGesture {
                                impactLight.impactOccurred()
                                editingTeam2Name = gameViewModel.player2.name
                                showEditTeam2 = true
                            }
                        }
                        .frame(maxWidth: 280) // Limit the width of the score boxes
                        
                        Spacer()
                        
                        // Info button
                        Button {
                            impactLight.impactOccurred()
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
                                    .font(.largeTitle)
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
                                        .font(.system(size: 50))
                                        .fontWeight(.semibold)
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
                                impactLight.impactOccurred()
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
                                impactLight.impactOccurred()
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
        .onAppear {
            impactLight.prepare()
            impactMedium.prepare()
        }
        .onChange(of: gameViewModel.gameEnded) { _, gameEnded in
            if gameEnded {
                let playerScores = gameViewModel.getAllPlayerScores()
                path.append(Routes.results(playerScores: playerScores))
            }
        }
        .sheet(isPresented: $showInfoModal) {
            InfoModalView()
        }
        .sheet(isPresented: $showEditTeam1) {
            EditTeamNameSheet(
                teamNumber: 1,
                currentName: $editingTeam1Name,
                onSave: {
                    TeamNameStorage.groupTeam1Name = editingTeam1Name
                    gameViewModel.updatePlayer1Name(editingTeam1Name)
                }
            )
        }
        .sheet(isPresented: $showEditTeam2) {
            EditTeamNameSheet(
                teamNumber: 2,
                currentName: $editingTeam2Name,
                onSave: {
                    TeamNameStorage.groupTeam2Name = editingTeam2Name
                    gameViewModel.updatePlayer2Name(editingTeam2Name)
                }
            )
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                        Button {
                            impactMedium.impactOccurred()
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
                            impactMedium.impactOccurred()
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

// MARK: - Info Modal View (Wrapper for UnifiedInfoModalView)

struct InfoModalView: View {
    var body: some View {
        UnifiedInfoModalView()
    }
}

// MARK: - Edit Team Name Sheet

struct EditTeamNameSheet: View {
    @Environment(\.dismiss) var dismiss
    let teamNumber: Int
    @Binding var currentName: String
    let onSave: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                GrayTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Edit Team \(teamNumber == 1 ? "One" : "Two") Name")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(GrayTheme.text)
                        
                        TextField("Enter team name", text: $currentName)
                            .font(.title3)
                            .padding()
                            .background(GrayTheme.card)
                            .foregroundColor(GrayTheme.text)
                            .cornerRadius(12)
                            .focused($isTextFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                saveAndDismiss()
                            }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(GrayTheme.text)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAndDismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(GrayTheme.gold)
                    .disabled(currentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .toolbarBackground(GrayTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveAndDismiss() {
        let trimmed = currentName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        currentName = trimmed
        onSave()
        dismiss()
    }
}

#Preview {
    GameScreen(path: .constant([]), category: .bible)
}

