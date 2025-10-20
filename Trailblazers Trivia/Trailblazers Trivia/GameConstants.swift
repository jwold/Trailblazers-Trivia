//
//  GameConstants.swift
//  Trailblazers Trivia
//
//  Created by Assistant on 10/19/25.
//

import Foundation

/// Game-related constants
struct GameConstants {
    /// Scoring constants
    struct Scoring {
        static let correctAnswerPoints: Double = 1.0
        static let wrongAnswerPenalty: Double = -0.5
        static let minimumScore: Double = 0.0
        static let winningScore: Double = 10.0
    }
    
    /// Single player game limits
    struct SinglePlayer {
        static let maxQuestions = 20
        static let winningScore = 10.0
    }
    
    /// Question validation constants
    struct Validation {
        static let minimumQuestionLength = 5
        static let minimumAnswerLength = 1
    }
}