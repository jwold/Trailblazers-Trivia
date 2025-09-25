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

// MARK: - JSON Question Model

/// Codable version of Question for JSON parsing
struct JSONQuestion: Codable {
    let id: Int
    let question: String
    let answer: String
    let reference: String
    
    /// Convert to domain Question model with UUID
    func toQuestion() -> Question {
        // Generate a UUID for the question since we don't trust the original IDs
        let uuid = UUID().uuidString
        
        return Question(
            id: uuid,
            question: question,
            answer: answer,
            difficulty: .easy // All questions in bible-easy.json are easy difficulty
        )
    }
}

// MARK: - JSON Question Repository

/// JSON file-based implementation of the question repository
class JSONQuestionRepository: QuestionRepositoryProtocol {
    
    private var questions: [Question] = []
    private var usedQuestionIds: Set<String> = []
    private var isLoaded = false
    
    init() {
        // Empty initializer - questions will be loaded lazily
    }
    
    /// Loads and returns all questions from JSON files
    private func loadAllQuestions() throws -> [Question] {
        var allQuestions: [Question] = []
        
        // Load easy questions
        if let easyQuestions = try loadQuestions(from: "bible-easy") {
            allQuestions.append(contentsOf: easyQuestions)
        }
        
        // Load hard questions
        if let hardQuestions = try loadQuestions(from: "bible-hard") {
            allQuestions.append(contentsOf: hardQuestions)
        }
        
        guard !allQuestions.isEmpty else {
            throw QuestionRepositoryError.noQuestionsFound
        }
        
        return allQuestions
    }
    
    private func loadQuestions(from fileName: String) throws -> [Question]? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("Warning: Could not find \(fileName).json in bundle")
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let jsonQuestions = try JSONDecoder().decode([JSONQuestion].self, from: data)
        
        // Filter out malformed questions and convert to Question model
        return jsonQuestions.compactMap { jsonQuestion in
            let question = jsonQuestion.toQuestion()
            
            // Basic validation to filter out incomplete or malformed questions
            guard !question.question.isEmpty,
                  !question.answer.isEmpty,
                  question.question.count > 5, // Reasonable minimum question length
                  question.answer.count > 1 else {
                print("Skipping malformed question with id: \(jsonQuestion.id)")
                return nil
            }
            
            return question
        }
    }
    
    func nextQuestion(for newDifficulty: Difficulty) async throws -> Question {
        // Load questions if not already loaded
        if !isLoaded {
            self.questions = try loadAllQuestions()
            self.isLoaded = true
        }
        
        let questionsForDifficulty = questions.filter { $0.difficulty == newDifficulty }
        
        guard !questionsForDifficulty.isEmpty else {
            throw QuestionRepositoryError.noQuestionsForDifficulty(newDifficulty)
        }
        
        let availableQuestions = questionsForDifficulty.filter { !usedQuestionIds.contains($0.id) }
        
        let selectedQuestion: Question
        
        if availableQuestions.isEmpty {
            // If all questions have been used, reset and start over
            resetUsedQuestions()
            selectedQuestion = questionsForDifficulty.randomElement()!
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

// MARK: - Question Repository Errors

enum QuestionRepositoryError: Error, LocalizedError {
    case noQuestionsFound
    case noQuestionsForDifficulty(Difficulty)
    case fileNotFound(String)
    case invalidJSONFormat
    
    var errorDescription: String? {
        switch self {
        case .noQuestionsFound:
            return "No questions were found in the repository"
        case .noQuestionsForDifficulty(let difficulty):
            return "No questions found for difficulty: \(difficulty)"
        case .fileNotFound(let fileName):
            return "File not found: \(fileName)"
        case .invalidJSONFormat:
            return "Invalid JSON format in question file"
        }
    }
}

// MARK: - Memory Question Repository

/// In-memory implementation of the question repository (fallback)
class MemoryQuestionRepository: QuestionRepositoryProtocol {
    
    private let questions: [Question]
    private var usedQuestionIds: Set<String> = []
    
    init() {
        // All questions pool - fallback questions
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
    static func create(type: RepositoryType = .json) -> QuestionRepositoryProtocol {
        switch type {
        case .json:
            return JSONQuestionRepository()
        case .memory:
            return MemoryQuestionRepository()
        }
    }
}

// MARK: - Repository Type Enum

/// Enum defining available repository types
enum RepositoryType {
    case json
    case memory
}