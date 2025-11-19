//
//  QuestionRepository.swift
//  TrailblazersTrivia
//
//  Created by Assistant on 9/24/25.
//

import Foundation

// MARK: - Question Repository Protocol

/// Protocol defining the interface for question data sources
protocol QuestionRepositoryProtocol {
    /// Get the next question, automatically managing used questions
    /// - Returns: The next available question, resetting the pool if all questions have been used
    func nextQuestion() throws -> Question
    
    /// Reset the used questions tracking for a fresh start
    func resetUsedQuestions()
}

// MARK: - JSON Question Model

/// Codable version of Question for JSON parsing
struct JSONQuestion: Codable {
    let id: Int
    let question: String
    let answer: String
    let wrongAnswers: [String]
    let reference: String
    
    /// Convert to domain Question model with UUID
    func toQuestion() -> Question {
        // Generate a UUID for the question since we don't trust the original IDs
        let uuid = UUID().uuidString
        
        return Question(
            id: uuid,
            question: question,
            answer: answer,
            wrongAnswers: wrongAnswers
        )
    }
}

// MARK: - JSON Question Repository

/// JSON file-based implementation of the question repository
class JSONQuestionRepository: QuestionRepositoryProtocol {
    
    private let category: TriviaCategory
    private let instanceId = UUID().uuidString
    
    private var questions: [Question] = []
    private var usedQuestionIds: Set<String> = []
    private var isLoaded = false
    private var isLoading = false
    
    // Static cache to share loaded questions across instances
    private static var questionCache: [TriviaCategory: [Question]] = [:]
    
    init(category: TriviaCategory) {
        self.category = category
    }
    
    /// Loads and returns all questions from JSON files
    private func loadAllQuestions() throws -> [Question] {
        // Check cache first
        if let cached = Self.questionCache[category] {
            return cached
        }
        
        var allQuestions: [Question] = []
        
        switch category {
        case .bible:
            if let bibleQuestions = try loadQuestions(from: "bible") {
                allQuestions.append(contentsOf: bibleQuestions)
            }
        case .usHistory:
            if let usHistoryQuestions = try loadQuestions(from: "ushistory") {
                allQuestions.append(contentsOf: usHistoryQuestions)
            }
        }
        
        guard !allQuestions.isEmpty else {
            throw QuestionRepositoryError.noQuestionsFound
        }
        
        // Cache the loaded questions
        Self.questionCache[category] = allQuestions
        
        return allQuestions
    }
    
    private func loadQuestions(from fileName: String) throws -> [Question]? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            throw QuestionRepositoryError.fileNotFound(fileName)
        }
        
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        let jsonQuestions = try decoder.decode([JSONQuestion].self, from: data)
        
        // Filter out malformed questions and convert to Question model
        let validQuestions = jsonQuestions.compactMap { jsonQuestion -> Question? in
            let question = jsonQuestion.toQuestion()
            
            // Quick validation without logging
            guard !question.question.isEmpty,
                  !question.answer.isEmpty,
                  question.question.count > GameConstants.Validation.minimumQuestionLength,
                  question.answer.count > GameConstants.Validation.minimumAnswerLength else {
                return nil
            }
            
            return question
        }
        
        return validQuestions
    }
    
    func nextQuestion() throws -> Question {
        // Check static cache first
        if !isLoaded {
            // Try to get from cache
            let cachedQuestions = Self.questionCache[category]
            
            if let cachedQuestions = cachedQuestions, !cachedQuestions.isEmpty {
                // Use cached questions
                #if DEBUG
                print("✅ Using cached questions for \(category.rawValue) (\(cachedQuestions.count) questions)")
                #endif
                self.questions = cachedQuestions
                self.isLoaded = true
            } else {
                // Need to load from disk
                #if DEBUG
                print("📂 Loading questions from disk for \(category.rawValue)...")
                #endif
                isLoading = true
                
                do {
                    let loadedQuestions = try loadAllQuestions()
                    self.questions = loadedQuestions
                    self.isLoaded = true
                    
                    // Store in cache for next time
                    Self.questionCache[category] = loadedQuestions
                    #if DEBUG
                    print("✅ Cached \(loadedQuestions.count) questions for \(category.rawValue)")
                    #endif
                } catch {
                    self.isLoading = false
                    throw error
                }
                
                self.isLoading = false
            }
        }
        
        // Ensure we have questions
        guard !questions.isEmpty else {
            throw QuestionRepositoryError.noQuestionsFound
        }
        
        // Get available questions
        let availableQuestions = questions.filter { !usedQuestionIds.contains($0.id) }
        
        let selectedQuestion: Question
        
        if availableQuestions.isEmpty {
            // Reset used questions and start over
            resetUsedQuestions()
            selectedQuestion = questions.randomElement() ?? questions[0]
        } else {
            selectedQuestion = availableQuestions.randomElement() ?? availableQuestions[0]
        }
        
        // Mark as used
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
    case fileNotFound(String)
    case invalidJSONFormat
    
    var errorDescription: String? {
        switch self {
        case .noQuestionsFound:
            return "No questions were found in the repository"
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
            Question(id: "easy_1", question: "How many close disciples did Jesus have?", answer: "12", wrongAnswers: ["10", "7"]),
            Question(id: "easy_2", question: "In what city was Jesus born?", answer: "Bethlehem", wrongAnswers: ["Nazareth", "Jerusalem"]),
            Question(id: "easy_3", question: "How many days did it rain during the flood?", answer: "40 days", wrongAnswers: ["30 days", "50 days"]),
            Question(id: "easy_4", question: "Who led the Israelites out of Egypt?", answer: "Moses", wrongAnswers: ["Abraham", "Joshua"]),
            Question(id: "easy_5", question: "What did God create on the first day?", answer: "Light", wrongAnswers: ["Earth", "Animals"]),
            Question(id: "easy_6", question: "How many books are in the New Testament?", answer: "27", wrongAnswers: ["39", "66"]),
            Question(id: "easy_7", question: "Who was the first man?", answer: "Adam", wrongAnswers: ["Noah", "Abraham"]),
            Question(id: "easy_8", question: "What was the first miracle of Jesus?", answer: "Turning water into wine", wrongAnswers: ["Healing the blind", "Walking on water"]),
            
            // Hard questions
            Question(id: "hard_1", question: "Who was the first king of Israel?", answer: "Saul", wrongAnswers: ["David", "Solomon"]),
            Question(id: "hard_2", question: "What is the shortest book in the New Testament?", answer: "2 John", wrongAnswers: ["3 John", "Jude"]),
            Question(id: "hard_3", question: "Who was the oldest man in the Bible?", answer: "Methuselah", wrongAnswers: ["Noah", "Adam"]),
            Question(id: "hard_4", question: "In what city did Paul meet Priscilla and Aquila?", answer: "Corinth", wrongAnswers: ["Rome", "Athens"]),
            Question(id: "hard_5", question: "What was the name of Abraham's nephew?", answer: "Lot", wrongAnswers: ["Isaac", "Jacob"]),
            Question(id: "hard_6", question: "How many sons did Jacob have?", answer: "12", wrongAnswers: ["10", "7"]),
            Question(id: "hard_7", question: "What was the name of the garden where Jesus prayed before his crucifixion?", answer: "Gethsemane", wrongAnswers: ["Eden", "Galilee"]),
            Question(id: "hard_8", question: "Who was the mother of John the Baptist?", answer: "Elizabeth", wrongAnswers: ["Mary", "Sarah"])
        ]
    }
    
    func nextQuestion() throws -> Question {
        // Filter out used questions
        let availableQuestions = questions.filter { !usedQuestionIds.contains($0.id) }
        
        let selectedQuestion: Question
        
        if availableQuestions.isEmpty {
            // If all questions have been used, reset and start over
            resetUsedQuestions()
            if let randomQuestion = questions.randomElement() {
                selectedQuestion = randomQuestion
            } else if let firstQuestion = questions.first {
                selectedQuestion = firstQuestion
            } else {
                throw QuestionRepositoryError.noQuestionsFound
            }
        } else {
            guard let randomQuestion = availableQuestions.randomElement() else {
                throw QuestionRepositoryError.noQuestionsFound
            }
            selectedQuestion = randomQuestion
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
    /// - Parameters:
    ///   - type: The type of repository to create
    ///   - category: The category of questions to load (default is .bible)
    /// - Returns: A question repository instance
    static func create(type: RepositoryType = .json, category: TriviaCategory = .bible) -> QuestionRepositoryProtocol {
        print("QuestionRepositoryFactory: Creating new instance for \(category)")
        switch type {
        case .json:
            return JSONQuestionRepository(category: category)
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

