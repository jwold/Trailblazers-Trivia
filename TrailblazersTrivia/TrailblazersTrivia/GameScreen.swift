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
                VStack(alignment: .leading, spacing: 12) {
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
                    
                    // Question Text - always visible
                    VStack(alignment: .leading, spacing: 12) {
                        Text(gameViewModel.currentQuestion.question)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(GrayTheme.text)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    
                    // Answer Options - Correct (blurred) and Incorrect
                    VStack(spacing: 16) {
                        // Correct Answer Card (blurred with eye icon)
                        correctAnswerButton
                        
                        // Incorrect Card
                        incorrectAnswerButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 0)
                .padding(.top, 20)
                .frame(maxHeight: .infinity)
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
    }
    
    // MARK: - Correct Answer Button (Two-Zone)
    
    private var correctAnswerButton: some View {
        HStack(spacing: 0) {
            // LEFT ZONE - Answer text (main tap area)
            Text(gameViewModel.currentQuestion.answer)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(GrayTheme.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .blur(radius: gameViewModel.showAnswer ? 0 : 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    if gameViewModel.showAnswer {
                        // When revealed: award point and proceed
                        impactMedium.impactOccurred()
                        gameViewModel.answeredCorrect()
                    }
                }
            
            // Vertical divider
            Rectangle()
                .fill(GrayTheme.text.opacity(0.2))
                .frame(width: 1)
                .frame(maxHeight: .infinity)
            
            // RIGHT ZONE - Eye toggle
            Image(systemName: gameViewModel.showAnswer ? "eye.slash.fill" : "eye.fill")
                .font(.title2)
                .foregroundColor(GrayTheme.gold)
                .frame(width: 70)
                .contentShape(Rectangle())
                .onTapGesture {
                    // Always active: toggle reveal
                    impactLight.impactOccurred()
                    gameViewModel.showAnswerToggle()
                }
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(GrayTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(GrayTheme.text.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Incorrect Answer Button
    
    private var incorrectAnswerButton: some View {
        Button {
            impactMedium.impactOccurred()
            gameViewModel.answeredWrong()
        } label: {
            Text("Incorrect")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(GrayTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(GrayTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(GrayTheme.text.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
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

