//
//  GameView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

struct GameView: View {
    @Binding var path: [Routes]

    @State private var currentScore = 0
    @State private var currentPlayer = "Persians's Turn"
    @State private var selectedDifficulty = "Hard"
    @State private var showAnswer = false
    @State private var gameEnded = false
    @State private var currentQuestion = TriviaQuestion(
        question: "How many close disciples did Jesus have?",
        answer: "12",
        reference: "Matthew 10:1-4"
    )
    
    let selectedCategory: String
    
    var body: some View {
        ZStack {
            // Clean background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Difficulty Toggle - matching screenshot style
                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        Button("Easy") {
                            selectedDifficulty = "Easy"
                            resetGame()
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedDifficulty == "Easy" ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(selectedDifficulty == "Easy" ? Color.black : Color.clear)
                        
                        Button("Hard") {
                            selectedDifficulty = "Hard"
                            resetGame()
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedDifficulty == "Hard" ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(selectedDifficulty == "Hard" ? Color.black : Color.clear)
                    }
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 200)
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
                            .font(.title)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Answer Display (when shown)
                    if showAnswer {
                        VStack(alignment: .center, spacing: 8) {
                            HStack {
                                Spacer()
                                Text(currentQuestion.answer)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }

                            if !currentQuestion.reference.isEmpty {
                                HStack {
                                    Spacer()
                                    Text(currentQuestion.reference)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Bottom Buttons Section
                VStack(spacing: 20) {
                    if !showAnswer {
                        Button("Show answer") {
                            showAnswer = true
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .padding(.horizontal, 20)
                    } else {
                        // Action Buttons
                        VStack(spacing: 20) {
                            Button("Correct") {
                                answerCorrect()
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            
                            Button("Wrong") {
                                answerWrong()
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
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
        currentScore += (selectedDifficulty == "Hard" ? 2 : 1)
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
                TriviaQuestion(question: "How many close disciples did Jesus have?", answer: "12", reference: "Matthew 10:1-4"),
                TriviaQuestion(question: "In what city was Jesus born?", answer: "Bethlehem", reference: "Matthew 2:1"),
                TriviaQuestion(question: "How many days did it rain during the flood?", answer: "40 days", reference: "Genesis 7:12"),
                TriviaQuestion(question: "Who led the Israelites out of Egypt?", answer: "Moses", reference: "Exodus 12:51"),
                TriviaQuestion(question: "Who was the first king of Israel?", answer: "Saul", reference: "1 Samuel 10:1")
            ]
            currentQuestion = questions.randomElement() ?? questions[0]
        }
    }
    
    private func getNextQuestion() -> TriviaQuestion {
        let questions = [
            TriviaQuestion(question: "How many close disciples did Jesus have?", answer: "12", reference: "Matthew 10:1-4"),
            TriviaQuestion(question: "In what city was Jesus born?", answer: "Bethlehem", reference: "Matthew 2:1"),
            TriviaQuestion(question: "How many days did it rain during the flood?", answer: "40 days", reference: "Genesis 7:12"),
            TriviaQuestion(question: "Who led the Israelites out of Egypt?", answer: "Moses", reference: "Exodus 12:51"),
            TriviaQuestion(question: "Who was the first king of Israel?", answer: "Saul", reference: "1 Samuel 10:1")
        ]
        return questions.randomElement() ?? questions[0]
    }
}

struct ResultsScreenData: Hashable {
    
}

// MARK: - Supporting Types
struct TriviaQuestion {
    let question: String
    let answer: String
    let reference: String
}
