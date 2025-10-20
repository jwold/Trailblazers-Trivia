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
    let wrongAnswers: [String]
    let reference: String
    
    /// Convert to domain Question model with UUID
    func toQuestion(difficulty: Difficulty) -> Question {
        // Generate a UUID for the question since we don't trust the original IDs
        let uuid = UUID().uuidString
        
        return Question(
            id: uuid,
            question: question,
            answer: answer,
            wrongAnswers: wrongAnswers,
            difficulty: difficulty
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
        print("loadAllQuestions called")
        var allQuestions: [Question] = []
        
        // Load questions from bible.json (treat all as hard difficulty)
        if let bibleQuestions = try loadQuestions(from: "bible") {
            allQuestions.append(contentsOf: bibleQuestions)
            print("Added \(bibleQuestions.count) bible questions")
        }
        
        // Load questions from us_history.json (treat all as hard difficulty)
        if let historyQuestions = try loadQuestions(from: "us_history") {
            allQuestions.append(contentsOf: historyQuestions)
            print("Added \(historyQuestions.count) US history questions")
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
        
        // Determine difficulty based on file name (all bible questions treated as hard)
        let difficulty: Difficulty = .hard
        
        // Filter out malformed questions and convert to Question model
        var validQuestions: [Question] = []
        
        for jsonQuestion in jsonQuestions {
            let question = jsonQuestion.toQuestion(difficulty: difficulty)
            
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
    
    func nextQuestion(for newDifficulty: Difficulty) async throws -> Question {
        print("nextQuestion called for difficulty: \(newDifficulty)")
        
        // Load questions if not already loaded
        if !isLoaded {
            print("Questions not loaded yet, loading...")
            self.questions = try loadAllQuestions()
            self.isLoaded = true
            print("Questions loaded successfully. Total: \(self.questions.count)")
        }
        
        // Filter questions by difficulty
        var questionsForDifficulty: [Question] = []
        for question in questions {
            if question.difficulty == newDifficulty {
                questionsForDifficulty.append(question)
            }
        }
        print("Found \(questionsForDifficulty.count) questions for difficulty \(newDifficulty)")
        
        guard !questionsForDifficulty.isEmpty else {
            print("Error: No questions found for difficulty \(newDifficulty)")
            throw QuestionRepositoryError.noQuestionsForDifficulty(newDifficulty)
        }
        
        // Filter out used questions
        var availableQuestions: [Question] = []
        for question in questionsForDifficulty {
            if !usedQuestionIds.contains(question.id) {
                availableQuestions.append(question)
            }
        }
        print("Available questions: \(availableQuestions.count), Used questions: \(usedQuestionIds.count)")
        
        let selectedQuestion: Question
        
        if availableQuestions.isEmpty {
            // If all questions have been used, reset and start over
            print("All questions used, resetting...")
            resetUsedQuestions()
            guard let randomQuestion = questionsForDifficulty.randomElement() else {
                throw QuestionRepositoryError.noQuestionsForDifficulty(newDifficulty)
            }
            selectedQuestion = randomQuestion
        } else {
            guard let randomQuestion = availableQuestions.randomElement() else {
                throw QuestionRepositoryError.noQuestionsForDifficulty(newDifficulty)
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
            Question(id: "easy_1", question: "How many close disciples did Jesus have?", answer: "12", wrongAnswers: ["10", "7"], difficulty: .easy),
            Question(id: "easy_2", question: "In what city was Jesus born?", answer: "Bethlehem", wrongAnswers: ["Nazareth", "Jerusalem"], difficulty: .easy),
            Question(id: "easy_3", question: "How many days did it rain during the flood?", answer: "40 days", wrongAnswers: ["30 days", "50 days"], difficulty: .easy),
            Question(id: "easy_4", question: "Who led the Israelites out of Egypt?", answer: "Moses", wrongAnswers: ["Abraham", "Joshua"], difficulty: .easy),
            Question(id: "easy_5", question: "What did God create on the first day?", answer: "Light", wrongAnswers: ["Earth", "Animals"], difficulty: .easy),
            Question(id: "easy_6", question: "How many books are in the New Testament?", answer: "27", wrongAnswers: ["39", "66"], difficulty: .easy),
            Question(id: "easy_7", question: "Who was the first man?", answer: "Adam", wrongAnswers: ["Noah", "Abraham"], difficulty: .easy),
            Question(id: "easy_8", question: "What was the first miracle of Jesus?", answer: "Turning water into wine", wrongAnswers: ["Healing the blind", "Walking on water"], difficulty: .easy),
            
            // Hard questions
            Question(id: "hard_1", question: "Who was the first king of Israel?", answer: "Saul", wrongAnswers: ["David", "Solomon"], difficulty: .hard),
            Question(id: "hard_2", question: "What is the shortest book in the New Testament?", answer: "2 John", wrongAnswers: ["3 John", "Jude"], difficulty: .hard),
            Question(id: "hard_3", question: "Who was the oldest man in the Bible?", answer: "Methuselah", wrongAnswers: ["Noah", "Adam"], difficulty: .hard),
            Question(id: "hard_4", question: "In what city did Paul meet Priscilla and Aquila?", answer: "Corinth", wrongAnswers: ["Rome", "Athens"], difficulty: .hard),
            Question(id: "hard_5", question: "What was the name of Abraham's nephew?", answer: "Lot", wrongAnswers: ["Isaac", "Jacob"], difficulty: .hard),
            Question(id: "hard_6", question: "How many sons did Jacob have?", answer: "12", wrongAnswers: ["10", "7"], difficulty: .hard),
            Question(id: "hard_7", question: "What was the name of the garden where Jesus prayed before his crucifixion?", answer: "Gethsemane", wrongAnswers: ["Eden", "Galilee"], difficulty: .hard),
            Question(id: "hard_8", question: "Who was the mother of John the Baptist?", answer: "Elizabeth", wrongAnswers: ["Mary", "Sarah"], difficulty: .hard)
        ]
    }
    
    func nextQuestion(for newDifficulty: Difficulty) async throws -> Question {
        // Filter questions by difficulty
        var questionsForDifficulty: [Question] = []
        for question in questions {
            if question.difficulty == newDifficulty {
                questionsForDifficulty.append(question)
            }
        }
        
        // Filter out used questions
        var availableQuestions: [Question] = []
        for question in questionsForDifficulty {
            if !usedQuestionIds.contains(question.id) {
                availableQuestions.append(question)
            }
        }
        
        let selectedQuestion: Question
        
        if availableQuestions.isEmpty {
            // If all questions have been used, reset and start over
            resetUsedQuestions()
            if let randomQuestion = questionsForDifficulty.randomElement() {
                selectedQuestion = randomQuestion
            } else if let firstQuestion = questionsForDifficulty.first {
                selectedQuestion = firstQuestion
            } else {
                throw QuestionRepositoryError.noQuestionsForDifficulty(newDifficulty)
            }
        } else {
            guard let randomQuestion = availableQuestions.randomElement() else {
                throw QuestionRepositoryError.noQuestionsForDifficulty(newDifficulty)
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
