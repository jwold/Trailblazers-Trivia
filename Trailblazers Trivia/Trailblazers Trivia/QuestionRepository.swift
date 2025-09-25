//
//  QuestionRepository.swift
//  Trailblazers Trivia
//
//  Created by Assistant on 9/24/25.
//

import Foundation

// MARK: - Question Repository Protocol

/// Protocol defining the interface for question data sources
protocol QuestionRepositoryProtocol {
    /// Get the next question for a specific difficulty, automatically managing used questions
    /// - Parameter newDifficulty: The difficulty level for the next question
    /// - Returns: The next available question, resetting the pool if all questions have been used
    func nextQuestion(for newDifficulty: Difficulty) async throws -> Question
    
    /// Reset the used questions tracking for a fresh start
    func resetUsedQuestions()
}

// MARK: - Memory Question Repository

/// In-memory implementation of the question repository
class MemoryQuestionRepository: QuestionRepositoryProtocol {
    
    private let questions: [Question]
    private var usedQuestionIds: Set<String> = []
    
    init() {
        // All questions pool
        self.questions = [
            // Easy questions
            Question(id: "easy_1", question: "How many close disciples did Jesus have?", answer: "12", difficulty: .easy),
            Question(id: "easy_2", question: "In what city was Jesus born?", answer: "Bethlehem", difficulty: .easy),
            Question(id: "easy_3", question: "How many days did it rain during the flood?", answer: "40 days", difficulty: .easy),
            Question(id: "easy_4", question: "Who led the Israelites out of Egypt?", answer: "Moses", difficulty: .easy),
            Question(id: "easy_5", question: "What did God create on the first day?", answer: "Light", difficulty: .easy),
            Question(id: "easy_6", question: "How many books are in the New Testament?", answer: "27", difficulty: .easy),
            Question(id: "easy_7", question: "Who was the first man?", answer: "Adam", difficulty: .easy),
            Question(id: "easy_8", question: "What was the first miracle of Jesus?", answer: "Turning water into wine", difficulty: .easy),
            
            // Hard questions
            Question(id: "hard_1", question: "Who was the first king of Israel?", answer: "Saul", difficulty: .hard),
            Question(id: "hard_2", question: "What is the shortest book in the New Testament?", answer: "2 John", difficulty: .hard),
            Question(id: "hard_3", question: "Who was the oldest man in the Bible?", answer: "Methuselah", difficulty: .hard),
            Question(id: "hard_4", question: "In what city did Paul meet Priscilla and Aquila?", answer: "Corinth", difficulty: .hard),
            Question(id: "hard_5", question: "What was the name of Abraham's nephew?", answer: "Lot", difficulty: .hard),
            Question(id: "hard_6", question: "How many sons did Jacob have?", answer: "12", difficulty: .hard),
            Question(id: "hard_7", question: "What was the name of the garden where Jesus prayed before his crucifixion?", answer: "Gethsemane", difficulty: .hard),
            Question(id: "hard_8", question: "Who was the mother of John the Baptist?", answer: "Elizabeth", difficulty: .hard)
        ]
    }
    
    func nextQuestion(for newDifficulty: Difficulty) async throws -> Question {
        let questionsForDifficulty = questions.filter { $0.difficulty == newDifficulty }
        let availableQuestions = questionsForDifficulty.filter { !usedQuestionIds.contains($0.id) }
        
        let selectedQuestion: Question
        
        if availableQuestions.isEmpty {
            // If all questions have been used, reset and start over
            resetUsedQuestions()
            selectedQuestion = questionsForDifficulty.randomElement() ?? questionsForDifficulty.first!
        } else {
            selectedQuestion = availableQuestions.randomElement()!
        }
        
        // Mark the selected question as used
        usedQuestionIds.insert(selectedQuestion.id)
        
        return selectedQuestion
    }
    
    func resetUsedQuestions() {
        usedQuestionIds.removeAll()
    }
}

// MARK: - Question Repository Factory

/// Factory class for creating question repository instances
class QuestionRepositoryFactory {
    
    /// Creates a question repository instance
    /// - Parameter type: The type of repository to create
    /// - Returns: A question repository instance
    static func create(type: RepositoryType = .memory) -> QuestionRepositoryProtocol {
        switch type {
        case .memory:
            return MemoryQuestionRepository()
        // Future implementations:
        // case .localStorage:
        //     return LocalStorageQuestionRepository()
        // case .api:
        //     return APIQuestionRepository()
        }
    }
}

// MARK: - Repository Type Enum

/// Enum defining available repository types
enum RepositoryType {
    case memory
    // Future types:
    // case localStorage
    // case api
}