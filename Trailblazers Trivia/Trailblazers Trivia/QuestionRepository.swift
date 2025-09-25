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
    /// Retrieve questions for a specific difficulty level
    /// - Parameter difficulty: The difficulty level to filter by
    /// - Returns: Array of questions matching the difficulty
    func getQuestions(for difficulty: Difficulty) async throws -> [Question]
    
    /// Retrieve all questions regardless of difficulty
    /// - Returns: Array of all available questions
    func getAllQuestions() async throws -> [Question]
    
    /// Get a random question for a specific difficulty, excluding already used questions
    /// - Parameters:
    ///   - difficulty: The difficulty level
    ///   - usedQuestionIds: Set of question IDs that have already been used
    /// - Returns: A random unused question, or nil if no unused questions available
    func getRandomQuestion(for difficulty: Difficulty, excluding usedQuestionIds: Set<String>) async throws -> Question?
}

// MARK: - Memory Question Repository

/// In-memory implementation of the question repository
class MemoryQuestionRepository: QuestionRepositoryProtocol {
    
    private let easyQuestions: [Question]
    private let hardQuestions: [Question]
    
    init() {
        // Easy questions pool
        self.easyQuestions = [
            Question(id: "easy_1", question: "How many close disciples did Jesus have?", answer: "12", difficulty: .easy),
            Question(id: "easy_2", question: "In what city was Jesus born?", answer: "Bethlehem", difficulty: .easy),
            Question(id: "easy_3", question: "How many days did it rain during the flood?", answer: "40 days", difficulty: .easy),
            Question(id: "easy_4", question: "Who led the Israelites out of Egypt?", answer: "Moses", difficulty: .easy),
            Question(id: "easy_5", question: "What did God create on the first day?", answer: "Light", difficulty: .easy),
            Question(id: "easy_6", question: "How many books are in the New Testament?", answer: "27", difficulty: .easy),
            Question(id: "easy_7", question: "Who was the first man?", answer: "Adam", difficulty: .easy),
            Question(id: "easy_8", question: "What was the first miracle of Jesus?", answer: "Turning water into wine", difficulty: .easy)
        ]
        
        // Hard questions pool
        self.hardQuestions = [
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
    
    func getQuestions(for difficulty: Difficulty) async throws -> [Question] {
        switch difficulty {
        case .easy:
            return easyQuestions
        case .hard:
            return hardQuestions
        }
    }
    
    func getAllQuestions() async throws -> [Question] {
        return easyQuestions + hardQuestions
    }
    
    func getRandomQuestion(for difficulty: Difficulty, excluding usedQuestionIds: Set<String>) async throws -> Question? {
        let questions = try await getQuestions(for: difficulty)
        let availableQuestions = questions.filter { !usedQuestionIds.contains($0.id) }
        
        if availableQuestions.isEmpty {
            // If all questions have been used, return a random question from the pool
            return questions.randomElement()
        }
        
        return availableQuestions.randomElement()
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