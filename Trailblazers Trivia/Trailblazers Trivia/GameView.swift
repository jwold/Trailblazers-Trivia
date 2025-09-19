//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentScore = 5
    @State private var totalPossiblePoints = 10
    @State private var currentPlayer = "Team Alpha"
    @State private var selectedDifficulty = "Easy"
    @State private var showAnswer = false
    @State private var gameEnded = false
    @State private var currentQuestion = TriviaQuestion(
        question: "Who was the first king of Israel?",
        answer: "Saul",
        reference: "1 Samuel 10:1"
    )
    
    let selectedCategory: String
    
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
                        Text(currentPlayer)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(currentScore)/\(totalPossiblePoints) points")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        // Difficulty Toggle
                        HStack(spacing: 20) {
                            Button("Easy") {
                                selectedDifficulty = "Easy"
                                resetGame()
                            }
                            .foregroundColor(selectedDifficulty == "Easy" ? .white : .blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(selectedDifficulty == "Easy" ? Color.blue : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            Button("Hard") {
                                selectedDifficulty = "Hard"
                                resetGame()
                            }
                            .foregroundColor(selectedDifficulty == "Hard" ? .white : .blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(selectedDifficulty == "Hard" ? Color.blue : Color.clear)
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
                    if !gameEnded {
                        VStack(spacing: 30) {
                            // Question Card
                            VStack(spacing: 20) {
                                Text(currentQuestion.question)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                if !showAnswer {
                                    Button("Show answer") {
                                        showAnswer = true
                                    }
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                } else {
                                    VStack(spacing: 10) {
                                        Text(currentQuestion.answer)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        if !currentQuestion.reference.isEmpty {
                                            Text(currentQuestion.reference)
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
                            if showAnswer {
                                VStack(spacing: 15) {
                                    HStack(spacing: 15) {
                                        Button("Correct") {
                                            answerCorrect()
                                        }
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        Button("Wrong") {
                                            answerWrong()
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
                                        skipQuestion()
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            Text("Game Complete!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Final Score: \(currentScore)/\(totalPossiblePoints)")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Button("Start New Game") {
                                resetGame()
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
    }
    
    // MARK: - Helper Functions
    private func resetGame() {
        currentScore = 0
        totalPossiblePoints = 10
        showAnswer = false
        gameEnded = false
        currentQuestion = getNextQuestion()
    }
    
    private func answerCorrect() {
        currentScore += (selectedDifficulty == "Hard" ? 2 : 1)
        nextQuestion()
    }
    
    private func answerWrong() {
        nextQuestion()
    }
    
    private func skipQuestion() {
        nextQuestion()
    }
    
    private func nextQuestion() {
        showAnswer = false
        // For demo purposes, just cycle through a few questions
        let questions = [
            TriviaQuestion(question: "Who was the first king of Israel?", answer: "Saul", reference: "1 Samuel 10:1"),
            TriviaQuestion(question: "In what city was Jesus born?", answer: "Bethlehem", reference: "Matthew 2:1"),
            TriviaQuestion(question: "How many days did it rain during the flood?", answer: "40 days", reference: "Genesis 7:12"),
            TriviaQuestion(question: "Who led the Israelites out of Egypt?", answer: "Moses", reference: "Exodus 12:51")
        ]
        
        // Simple logic to cycle through questions or end game
        if currentScore >= 8 || totalPossiblePoints <= 0 {
            gameEnded = true
        } else {
            currentQuestion = questions.randomElement() ?? questions[0]
        }
    }
    
    private func getNextQuestion() -> TriviaQuestion {
        let questions = [
            TriviaQuestion(question: "Who was the first king of Israel?", answer: "Saul", reference: "1 Samuel 10:1"),
            TriviaQuestion(question: "In what city was Jesus born?", answer: "Bethlehem", reference: "Matthew 2:1"),
            TriviaQuestion(question: "How many days did it rain during the flood?", answer: "40 days", reference: "Genesis 7:12"),
            TriviaQuestion(question: "Who led the Israelites out of Egypt?", answer: "Moses", reference: "Exodus 12:51")
        ]
        return questions.randomElement() ?? questions[0]
    }
}

// MARK: - Supporting Types
struct TriviaQuestion {
    let question: String
    let answer: String
    let reference: String
}

#Preview {
    GameView(selectedCategory: "Bible")
}
