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
    case animals = "Animals"
    
    var displayName: String {
        rawValue
    }
    
    var description: String {
        switch self {
        case .bible:
            return "Test your biblical knowledge"
        case .usHistory:
            return "Test your US History knowledge"
        case .animals:
            return "Test your animal knowledge"
        }
    }
    
    var iconName: String {
        switch self {
        case .bible:
            return "book.closed"
        case .usHistory:
            return "flag.fill"
        case .animals:
            return "pawprint.fill"
        }
    }
}

// MARK: - Team Name Generator

struct TeamNameGenerator {
    
    /// Generate two team names for the given category and mode
    /// - Parameters:
    ///   - category: The trivia category
    ///   - isCouchMode: Whether this is for Couch Mode (2P) vs Group mode
    /// - Returns: A tuple of two team names (uses stored custom names if available)
    static func generateTeamNames(for category: TriviaCategory, isCouchMode: Bool = false) -> (team1: String, team2: String) {
        // For Couch Mode (2P), use stored Player names
        if isCouchMode {
            return (TeamNameStorage.couchPlayer1Name, TeamNameStorage.couchPlayer2Name)
        }
        
        // For Group mode, use stored Team names
        return (TeamNameStorage.groupTeam1Name, TeamNameStorage.groupTeam2Name)
    }
    
    /// Get a team name from the specified category
    /// - Parameter category: The trivia category
    /// - Returns: A team name
    static func randomTeamName(for category: TriviaCategory) -> String {
        return "Team"
    }
}
