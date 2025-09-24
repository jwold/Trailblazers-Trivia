//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

struct GameScreen: View {
    @Binding var path: [Routes]

    @State private var currentScore = 0
    @State private var currentPlayer = "Persians's Turn"
    @State private var selectedDifficulty = 1 // 0 = Easy, 1 = Hard
    @State private var showAnswer = false
    @State private var gameEnded = false
    @State private var currentQuestion = Question(
        question: "How many close disciples did Jesus have?",
        answer: "12",
        difficulty: .easy
    )
    
    let selectedCategory: String = "Bible"
    
    var body: some View {
        ZStack {
            // Clean background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Difficulty Segmented Control - Stocks app style
                VStack(spacing: 16) {
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        Text("Easy").tag(0)
                        Text("Hard").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    .onChange(of: selectedDifficulty) { _ in
                        resetGame()
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Player info above question
                    HStack {
                        Spacer()
                        Text("\(currentPlayer) • \(currentScore) Points")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Question Text - larger and centered
                    HStack {
                        Spacer()
                        Text(currentQuestion.question)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Answer Display (when shown)
                    if showAnswer {
                        VStack(spacing: 16) {
                            Text(currentQuestion.answer)
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
                    if !showAnswer {
                        Button {
                            showAnswer = true
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
                                answerCorrect()
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
                                answerWrong()
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
                                showAnswer = false
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
    
    
    // MARK: - Helper Functions
    private func resetGame() {
        currentScore = 0
        showAnswer = false
        gameEnded = false
        currentQuestion = getNextQuestion()
    }
    
    private func answerCorrect() {
        currentScore += (selectedDifficulty == 1 ? 2 : 1)
        nextQuestion()
    }
    
    private func answerWrong() {
        nextQuestion()
    }
    
    private func nextQuestion() {
        showAnswer = false
        // Simple logic to cycle through questions or end game
        if currentScore >= 10 {
            gameEnded = true
        } else {
            let questions = [
                Question(question: "How many close disciples did Jesus have?", answer: "12", difficulty: .easy),
                Question(question: "In what city was Jesus born?", answer: "Bethlehem", difficulty: .easy),
                Question(question: "How many days did it rain during the flood?", answer: "40 days", difficulty: .easy),
                Question(question: "Who led the Israelites out of Egypt?", answer: "Moses", difficulty: .easy),
                Question(question: "Who was the first king of Israel?", answer: "Saul", difficulty: .hard)
            ]
            currentQuestion = questions.randomElement() ?? questions[0]
        }
    }
    
    private func getNextQuestion() -> Question {
        let questions = [
            Question(question: "How many close disciples did Jesus have?", answer: "12", difficulty: .easy),
            Question(question: "In what city was Jesus born?", answer: "Bethlehem", difficulty: .easy),
            Question(question: "How many days did it rain during the flood?", answer: "40 days", difficulty: .easy),
            Question(question: "Who led the Israelites out of Egypt?", answer: "Moses", difficulty: .easy),
            Question(question: "Who was the first king of Israel?", answer: "Saul", difficulty: .hard)
        ]
        return questions.randomElement() ?? questions[0]
    }
}

struct Player {
    let id: String
    let name: String
}

enum Difficulty {
    case easy
    case hard
}

struct Question {
    let question: String
    let answer: String
    let difficulty: Difficulty
}

#Preview {
    GameScreen(path: .constant([]))
}
