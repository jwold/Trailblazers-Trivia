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
    
    /// Generate two team names for the given category
    /// - Parameter category: The trivia category
    /// - Returns: A tuple of two team names
    static func generateTeamNames(for category: TriviaCategory) -> (team1: String, team2: String) {
        // For Bible and US History, use simple team names
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
