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
    /// Get the next question, automatically managing used questions
    /// - Returns: The next available question, resetting the pool if all questions have been used
    func nextQuestion() async throws -> Question
    
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
    
    private var questions: [Question] = []
    private var usedQuestionIds: Set<String> = []
    private var isLoaded = false
    
    init(category: TriviaCategory) {
        self.category = category
    }
    
    /// Loads and returns all questions from JSON files
    private func loadAllQuestions() throws -> [Question] {
        print("loadAllQuestions called")
        var allQuestions: [Question] = []
        
        switch category {
        case .bible:
            if let bibleQuestions = try loadQuestions(from: "bible") {
                allQuestions.append(contentsOf: bibleQuestions)
                print("Added \(bibleQuestions.count) bible questions")
            }
        }
        
        print("Total questions loaded: \(allQuestions.count)")
        
        guard !allQuestions.isEmpty else {
            print("Error: No questions found after loading")
            throw QuestionRepositoryError.noQuestionsFound
        }
        
        return allQuestions
    }
    
    private func loadQuestions(from fileName: String) throws -> [Question]? {
        print("Loading questions from \(fileName).json...")
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("Error: Could not find \(fileName).json in bundle")
            throw QuestionRepositoryError.fileNotFound(fileName)
        }
        
        print("Found file at path: \(path)")
        
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        print("Successfully loaded \(data.count) bytes of data")
        
        let decoder = JSONDecoder()
        let jsonQuestions = try decoder.decode([JSONQuestion].self, from: data)
        print("Successfully decoded \(jsonQuestions.count) questions from JSON")
        
        // Filter out malformed questions and convert to Question model
        var validQuestions: [Question] = []
        
        for jsonQuestion in jsonQuestions {
            let question = jsonQuestion.toQuestion()
            
            // Basic validation - check each condition separately
            if question.question.isEmpty {
                print("Skipping question with empty question text, id: \(jsonQuestion.id)")
                continue
            }
            
            if question.answer.isEmpty {
                print("Skipping question with empty answer, id: \(jsonQuestion.id)")
                continue
            }
            
            let minQuestionLength = GameConstants.Validation.minimumQuestionLength
            if question.question.count <= minQuestionLength {
                print("Skipping question with insufficient length, id: \(jsonQuestion.id)")
                continue
            }
            
            let minAnswerLength = GameConstants.Validation.minimumAnswerLength
            if question.answer.count <= minAnswerLength {
                print("Skipping question with insufficient answer length, id: \(jsonQuestion.id)")
                continue
            }
            
            // If we get here, the question is valid
            validQuestions.append(question)
        }
        
        print("Successfully processed \(validQuestions.count) valid questions")
        return validQuestions
    }
    
    func nextQuestion() async throws -> Question {
        print("nextQuestion called")
        
        // Load questions if not already loaded
        if !isLoaded {
            print("Questions not loaded yet, loading...")
            self.questions = try loadAllQuestions()
            self.isLoaded = true
            print("Questions loaded successfully. Total: \(self.questions.count)")
        }
        
        // Filter out used questions
        let availableQuestions = questions.filter { !usedQuestionIds.contains($0.id) }
        print("Available questions: \(availableQuestions.count), Used questions: \(usedQuestionIds.count)")
        
        let selectedQuestion: Question
        
        if availableQuestions.isEmpty {
            // If all questions have been used, reset and start over
            print("All questions used, resetting...")
            resetUsedQuestions()
            guard let randomQuestion = questions.randomElement() else {
                throw QuestionRepositoryError.noQuestionsFound
            }
            selectedQuestion = randomQuestion
        } else {
            guard let randomQuestion = availableQuestions.randomElement() else {
                throw QuestionRepositoryError.noQuestionsFound
            }
            selectedQuestion = randomQuestion
        }
        
        // Mark the selected question as used
        usedQuestionIds.insert(selectedQuestion.id)
        
        print("Selected question: \(selectedQuestion.question)")
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
    
    func nextQuestion() async throws -> Question {
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

