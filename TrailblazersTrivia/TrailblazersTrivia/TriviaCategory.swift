//
//  TriviaCategory.swift
//  TrailblazersTrivia
//
//  Created by Assistant on 10/20/25.
//

import Foundation

// MARK: - Trivia Category

enum TriviaCategory: String, CaseIterable, Hashable {
    case bible = "Bible"
    case usHistory = "US History"
    
    var displayName: String {
        rawValue
    }
    
    var description: String {
        switch self {
        case .bible:
            return "Test your biblical knowledge"
        case .usHistory:
            return "Test your US History knowledge"
        }
    }
    
    var iconName: String {
        switch self {
        case .bible:
            return "book.closed"
        case .usHistory:
            return "flag.fill"
        }
    }
}

// MARK: - Team Name Generator

struct TeamNameGenerator {
    
    /// Generate two team names for the given category and mode
    /// - Parameters:
    ///   - category: The trivia category
    ///   - isCouchMode: Whether this is for Couch Mode (2P) vs Group mode
    /// - Returns: A tuple of two team names
    static func generateTeamNames(for category: TriviaCategory, isCouchMode: Bool = false) -> (team1: String, team2: String) {
        // For Couch Mode (2P), use Player names
        if isCouchMode {
            return ("Player 1", "Player 2")
        }
        
        // For Group mode, use Team names
        switch category {
        case .bible, .usHistory:
            return ("Team One", "Team Two")
        }
    }
    
    /// Get a team name from the specified category
    /// - Parameter category: The trivia category
    /// - Returns: A team name
    static func randomTeamName(for category: TriviaCategory) -> String {
        return "Team"
    }
}
