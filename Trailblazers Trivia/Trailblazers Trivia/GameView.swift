//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentScore = 0
    @State private var currentPlayer = "Rechabites's Turn"
    @State private var selectedDifficulty = "Easy"
    @State private var showAnswer = false
    @State private var gameEnded = false
    @State private var currentQuestion = TriviaQuestion(
        question: "Who restored Paul's sight after the Lord blinded him?",
        answer: "Ananias",
        reference: "Acts 9:17-18"
    )
    
    let selectedCategory: String
    
    var body: some View {
        ZStack {
            // Clean background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 16) {
                    // Player info in center
                    VStack(spacing: 4) {
                        Text(currentPlayer)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(currentScore) points")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Difficulty Toggle - matching screenshot style
                    HStack(spacing: 0) {
                        Button("Easy") {
                            selectedDifficulty = "Easy"
                            resetGame()
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedDifficulty == "Easy" ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(selectedDifficulty == "Easy" ? Color.black : Color.clear)
                        
                        Button("Hard") {
                            selectedDifficulty = "Hard"
                            resetGame()
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedDifficulty == "Hard" ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(selectedDifficulty == "Hard" ? Color.black : Color.clear)
                    }
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(width: 160)
                }
                .padding(.bottom, 40)
                
                // Content Section
                VStack(alignment: .leading, spacing: 20) {
                    // Question Text - larger and left aligned
                    HStack {
                        Text(currentQuestion.question)
                            .font(.title)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Show Answer Button or Answer Display
                    if !showAnswer {
                        VStack(spacing: 12) {
                            HStack {
                                Button("Show answer") {
                                    showAnswer = true
                                }
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                Spacer()
                            }
                            
                            HStack {
                                Button("End") {
                                    dismiss()
                                }
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(currentQuestion.answer)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            if !currentQuestion.reference.isEmpty {
                                HStack {
                                    Text(currentQuestion.reference)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button("Correct") {
                                answerCorrect()
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            
                            Button("Wrong") {
                                answerWrong()
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .font(.headline)
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
        currentScore += (selectedDifficulty == "Hard" ? 2 : 1)
        nextQuestion()
    }
    
    private func answerWrong() {
        nextQuestion()
    }
    
    private func nextQuestion() {
        showAnswer = false
        // For demo purposes, just cycle through a few questions
        let questions = [
            TriviaQuestion(question: "Who restored Paul's sight after the Lord blinded him?", answer: "Ananias", reference: "Acts 9:17-18"),
            TriviaQuestion(question: "In what city was Jesus born?", answer: "Bethlehem", reference: "Matthew 2:1"),
            TriviaQuestion(question: "How many days did it rain during the flood?", answer: "40 days", reference: "Genesis 7:12"),
            TriviaQuestion(question: "Who led the Israelites out of Egypt?", answer: "Moses", reference: "Exodus 12:51"),
            TriviaQuestion(question: "Who was the first king of Israel?", answer: "Saul", reference: "1 Samuel 10:1")
        ]
        
        // Simple logic to cycle through questions or end game
        if currentScore >= 10 {
            gameEnded = true
        } else {
            currentQuestion = questions.randomElement() ?? questions[0]
        }
    }
    
    private func getNextQuestion() -> TriviaQuestion {
        let questions = [
            TriviaQuestion(question: "Who restored Paul's sight after the Lord blinded him?", answer: "Ananias", reference: "Acts 9:17-18"),
            TriviaQuestion(question: "In what city was Jesus born?", answer: "Bethlehem", reference: "Matthew 2:1"),
            TriviaQuestion(question: "How many days did it rain during the flood?", answer: "40 days", reference: "Genesis 7:12"),
            TriviaQuestion(question: "Who led the Israelites out of Egypt?", answer: "Moses", reference: "Exodus 12:51"),
            TriviaQuestion(question: "Who was the first king of Israel?", answer: "Saul", reference: "1 Samuel 10:1")
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
