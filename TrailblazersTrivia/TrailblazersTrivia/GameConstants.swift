//
//  GameConstants.swift
//  TrailblazersTrivia
//
//  Created by Assistant on 10/19/25.
//

import Foundation

/// Game-related constants
struct GameConstants {
    /// Game limits and scoring
    struct Game {
        static let winningScore: Double = 10.0
        static let maxQuestions = 20
    }
    
    /// Question validation constants
    struct Validation {
        static let minimumQuestionLength = 5
        static let minimumAnswerLength = 1
    }
}