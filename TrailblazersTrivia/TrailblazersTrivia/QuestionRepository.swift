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
    /// - Parameter category: The trivia category to get a question from
    /// - Returns: The next available question, resetting the pool if all questions have been used
    func nextQuestion(category: TriviaCategory) throws -> Question
    
    func resetUsedQuestions()
}

/// Codable version of Question for JSON parsing
struct JSONQuestion: Codable {
    let id: Int
    let question: String
    let answer: String
    let wrongAnswers: [String]
    let reference: String
    
    /// Convert to domain Question model with UUID
    func toQuestion() -> Question {
        let uuid = UUID().uuidString
        
        return Question(
            id: uuid,
            question: question,
            answer: answer,
            wrongAnswers: wrongAnswers
        )
    }
}

/// JSON file-based implementation of the question repository
class JSONQuestionRepository: QuestionRepositoryProtocol {
    private var currentlyLoadedCategory: TriviaCategory?
    
    private var loadedQuestions: [Question] = []
    
    private var usedQuestionIds: Set<String> = []
    
    func nextQuestion(category: TriviaCategory) throws -> Question {
        if currentlyLoadedCategory != category {
            loadedQuestions = try loadAllQuestions(for: category)
            currentlyLoadedCategory = category
            usedQuestionIds.removeAll()
        }
        
        guard !loadedQuestions.isEmpty else {
            throw QuestionRepositoryError.noQuestionsFound
        }
        
        let availableQuestions = loadedQuestions.filter { !usedQuestionIds.contains($0.id) }
        
        let selectedQuestion: Question
        
        if availableQuestions.isEmpty {
            usedQuestionIds.removeAll()
            selectedQuestion = loadedQuestions.randomElement() ?? loadedQuestions[0]
        } else {
            selectedQuestion = availableQuestions.randomElement() ?? availableQuestions[0]
        }
        
        usedQuestionIds.insert(selectedQuestion.id)
        
        return selectedQuestion
    }
    
    func resetUsedQuestions() {
        usedQuestionIds.removeAll()
    }
    
    private func loadAllQuestions(for category: TriviaCategory) throws -> [Question] {
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
        case .animals:
            if let animalsQuestions = try loadQuestions(from: "animals") {
                allQuestions.append(contentsOf: animalsQuestions)
            }
        }
        
        guard !allQuestions.isEmpty else {
            throw QuestionRepositoryError.noQuestionsFound
        }
        
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
        
        let validQuestions = jsonQuestions.compactMap { jsonQuestion -> Question? in
            let question = jsonQuestion.toQuestion()
            
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
}

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

