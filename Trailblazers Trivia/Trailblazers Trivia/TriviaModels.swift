//
//  TriviaModels.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import Foundation
import Combine

struct TriviaQuestion: Codable, Identifiable {
    let id: Int
    let question: String
    let answer: String
    let reference: String
}

enum Difficulty: String, CaseIterable {
    case easy = "easy"
    case hard = "hard"
    
    var points: Int {
        switch self {
        case .easy: return 1
        case .hard: return 3
        }
    }
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .hard: return "Hard"
        }
    }
}

enum TriviaGameCategory: String, CaseIterable {
    case bible = "bible"
    case animals = "animals"
    case usHistory = "us_history"
    case worldHistory = "world_history"
    case geography = "geography"
    
    var displayName: String {
        switch self {
        case .bible: return "Bible"
        case .animals: return "Animals"
        case .usHistory: return "US History"
        case .worldHistory: return "World History"
        case .geography: return "Geography"
        }
    }
    
    var icon: String {
        switch self {
        case .bible: return "book.closed"
        case .animals: return "pawprint"
        case .usHistory: return "flag"
        case .worldHistory: return "globe"
        case .geography: return "location"
        }
    }
}

class GameState: ObservableObject {
    @Published var currentPlayer: String = "Player 1"
    @Published var currentScore: Int = 0
    @Published var totalPossiblePoints: Int = 0
    @Published var selectedDifficulty: Difficulty = .easy
    @Published var currentQuestion: TriviaQuestion?
    @Published var showAnswer: Bool = false
    @Published var gameEnded: Bool = false
    
    private var questionBank: [TriviaQuestion] = []
    private var usedQuestionIds: Set<Int> = []
    
    init() {}
    
    func startGame(with category: TriviaGameCategory, difficulty: Difficulty) {
        selectedDifficulty = difficulty
        loadQuestions(for: category, difficulty: difficulty)
        resetGame()
        nextQuestion()
    }
    
    func resetGame() {
        currentScore = 0
        totalPossiblePoints = 0
        usedQuestionIds.removeAll()
        showAnswer = false
        gameEnded = false
    }
    
    func nextQuestion() {
        showAnswer = false
        
        let availableQuestions = questionBank.filter { !usedQuestionIds.contains($0.id) }
        
        if availableQuestions.isEmpty {
            gameEnded = true
            currentQuestion = nil
        } else {
            currentQuestion = availableQuestions.randomElement()
            if let question = currentQuestion {
                usedQuestionIds.insert(question.id)
            }
        }
    }
    
    func answerCorrect() {
        currentScore += selectedDifficulty.points
        totalPossiblePoints += selectedDifficulty.points
        nextQuestion()
    }
    
    func answerWrong() {
        totalPossiblePoints += selectedDifficulty.points
        nextQuestion()
    }
    
    func skipQuestion() {
        if let question = currentQuestion {
            usedQuestionIds.remove(question.id)
        }
        nextQuestion()
    }
    
    func showAnswerToggle() {
        showAnswer.toggle()
    }
    
    private func loadQuestions(for category: TriviaGameCategory, difficulty: Difficulty) {
        questionBank = generateSampleQuestions(for: category, difficulty: difficulty)
    }
}

// Sample questions based on your JSON structure
func generateSampleQuestions(for category: TriviaGameCategory, difficulty: Difficulty) -> [TriviaQuestion] {
    switch (category, difficulty) {
    case (.bible, .easy):
        return [
            TriviaQuestion(id: 1, question: "Who was the first man created by God?", answer: "Adam", reference: "Genesis 2:7"),
            TriviaQuestion(id: 3, question: "Who built an ark to survive the flood?", answer: "Noah", reference: "Genesis 6:14"),
            TriviaQuestion(id: 5, question: "Who was swallowed by a great fish?", answer: "Jonah", reference: "Jonah 1:17"),
            TriviaQuestion(id: 7, question: "What are the first three words in the Bible?", answer: "In the beginning", reference: "Genesis 1:1"),
            TriviaQuestion(id: 9, question: "Who was the strongest man in the Bible?", answer: "Samson", reference: "Judges 16")
        ]
    case (.bible, .hard):
        return [
            TriviaQuestion(id: 101, question: "Which prophet saw a vision of dry bones coming to life?", answer: "Ezekiel", reference: "Ezekiel 37"),
            TriviaQuestion(id: 103, question: "Who was the king of Salem who blessed Abraham?", answer: "Melchizedek", reference: "Genesis 14:18"),
            TriviaQuestion(id: 105, question: "What was the name of Abraham's wife before God changed it?", answer: "Sarai", reference: "Genesis 17:15"),
            TriviaQuestion(id: 107, question: "Which book of the Bible contains the shortest verse?", answer: "John", reference: "John 11:35"),
            TriviaQuestion(id: 109, question: "Who was the tax collector that climbed a sycamore tree?", answer: "Zacchaeus", reference: "Luke 19:4")
        ]
    case (.animals, .easy):
        return [
            TriviaQuestion(id: 1981, question: "What is the largest land animal?", answer: "Elephant", reference: ""),
            TriviaQuestion(id: 1983, question: "Which animal is known as the king of the jungle?", answer: "Lion", reference: ""),
            TriviaQuestion(id: 1987, question: "What do you call a baby kangaroo?", answer: "Joey", reference: ""),
            TriviaQuestion(id: 1989, question: "Which animal is known for its black and white stripes?", answer: "Zebra", reference: ""),
            TriviaQuestion(id: 1991, question: "What sound does a cow make?", answer: "Moo", reference: "")
        ]
    case (.animals, .hard):
        return [
            TriviaQuestion(id: 1985, question: "What is the only mammal that lays eggs?", answer: "Platypus", reference: ""),
            TriviaQuestion(id: 1993, question: "How many chambers does a cow's stomach have?", answer: "Four", reference: ""),
            TriviaQuestion(id: 1995, question: "What is the fastest land animal?", answer: "Cheetah", reference: ""),
            TriviaQuestion(id: 1997, question: "Which bird cannot fly backwards?", answer: "Hummingbird", reference: ""),
            TriviaQuestion(id: 1999, question: "What is the largest species of shark?", answer: "Whale shark", reference: "")
        ]
    case (.usHistory, .easy):
        return [
            TriviaQuestion(id: 2981, question: "Who was the first President of the United States?", answer: "George Washington", reference: ""),
            TriviaQuestion(id: 2982, question: "In what year did the United States declare independence?", answer: "1776", reference: ""),
            TriviaQuestion(id: 2983, question: "Which war was fought between the North and South?", answer: "Civil War", reference: ""),
            TriviaQuestion(id: 2984, question: "Who wrote the Declaration of Independence?", answer: "Thomas Jefferson", reference: ""),
            TriviaQuestion(id: 2985, question: "What is the capital of the United States?", answer: "Washington D.C.", reference: "")
        ]
    case (.usHistory, .hard):
        return [
            TriviaQuestion(id: 3001, question: "Which amendment gave women the right to vote?", answer: "19th Amendment", reference: ""),
            TriviaQuestion(id: 3003, question: "Who was president during the Louisiana Purchase?", answer: "Thomas Jefferson", reference: ""),
            TriviaQuestion(id: 3005, question: "What year did the Stock Market crash that started the Great Depression?", answer: "1929", reference: ""),
            TriviaQuestion(id: 3007, question: "Which president served the shortest term in office?", answer: "William Henry Harrison", reference: ""),
            TriviaQuestion(id: 3009, question: "What was the first state to secede from the Union?", answer: "South Carolina", reference: "")
        ]
    case (.worldHistory, .easy):
        return [
            TriviaQuestion(id: 4001, question: "Which ancient wonder of the world was located in Egypt?", answer: "Great Pyramid of Giza", reference: ""),
            TriviaQuestion(id: 4003, question: "Who was the famous queen of ancient Egypt?", answer: "Cleopatra", reference: ""),
            TriviaQuestion(id: 4005, question: "Which empire was ruled by Julius Caesar?", answer: "Roman Empire", reference: ""),
            TriviaQuestion(id: 4007, question: "What was the name of the ship that sank in 1912?", answer: "Titanic", reference: ""),
            TriviaQuestion(id: 4009, question: "Which country gave the Statue of Liberty to the United States?", answer: "France", reference: "")
        ]
    case (.worldHistory, .hard):
        return [
            TriviaQuestion(id: 5149, question: "Which battle marked the end of Napoleon's reign?", answer: "Battle of Waterloo", reference: ""),
            TriviaQuestion(id: 5161, question: "What was the name of the first university in the world?", answer: "University of Bologna", reference: ""),
            TriviaQuestion(id: 5163, question: "Who was the first person to circumnavigate the globe?", answer: "Ferdinand Magellan", reference: ""),
            TriviaQuestion(id: 5165, question: "Which dynasty built the Forbidden City in China?", answer: "Ming Dynasty", reference: ""),
            TriviaQuestion(id: 5167, question: "What year did the Berlin Wall fall?", answer: "1989", reference: "")
        ]
    case (.geography, .easy):
        return [
            TriviaQuestion(id: 5606, question: "What is the largest continent?", answer: "Asia", reference: ""),
            TriviaQuestion(id: 5607, question: "Which river is the longest in the world?", answer: "Nile River", reference: ""),
            TriviaQuestion(id: 5608, question: "What is the smallest country in the world?", answer: "Vatican City", reference: ""),
            TriviaQuestion(id: 5609, question: "Which mountain range contains Mount Everest?", answer: "Himalayas", reference: ""),
            TriviaQuestion(id: 5610, question: "What is the capital of France?", answer: "Paris", reference: "")
        ]
    case (.geography, .hard):
        return [
            TriviaQuestion(id: 5701, question: "What is the deepest point in Earth's oceans?", answer: "Mariana Trench", reference: ""),
            TriviaQuestion(id: 5703, question: "Which African country has three capital cities?", answer: "South Africa", reference: ""),
            TriviaQuestion(id: 5705, question: "What is the driest desert in the world?", answer: "Atacama Desert", reference: ""),
            TriviaQuestion(id: 5707, question: "Which strait separates Europe and Africa?", answer: "Strait of Gibraltar", reference: ""),
            TriviaQuestion(id: 5709, question: "What is the highest capital city in the world?", answer: "La Paz", reference: "")
        ]
    }
}
