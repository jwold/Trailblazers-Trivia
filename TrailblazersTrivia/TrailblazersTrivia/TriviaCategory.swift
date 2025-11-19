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
    
    var teamNames: [String] {
        switch self {
        case .bible:
            return TeamNameGenerator.biblicalNations
        case .usHistory:
            return TeamNameGenerator.usHistoryTeams
        }
    }
}

// MARK: - Team Name Generator

struct TeamNameGenerator {
    
    // 10 Biblical Nations
    static let biblicalNations = [
        "Israelites",
        "Philistines",
        "Egyptians",
        "Babylonians",
        "Assyrians",
        "Persians",
        "Romans",
        "Greeks",
        "Moabites",
        "Edomites"
    ]
    
    // 10 US History Teams
    static let usHistoryTeams = [
        "Minutemen",
        "Founding Fathers",
        "Patriots",
        "Rebels",
        "Union",
        "Confederates",
        "Pioneers",
        "Colonists",
        "Federalists",
        "Revolutionaries"
    ]
    
    /// Generate two random team names for the given category
    /// - Parameter category: The trivia category
    /// - Returns: A tuple of two unique team names
    static func generateTeamNames(for category: TriviaCategory) -> (team1: String, team2: String) {
        let availableNames = category.teamNames
        
        // Ensure we have at least 2 names
        guard availableNames.count >= 2 else {
            return ("Team 1", "Team 2")
        }
        
        // Shuffle the names and take the first two
        let shuffledNames = availableNames.shuffled()
        return (shuffledNames[0], shuffledNames[1])
    }
    
    /// Get a random team name from the specified category
    /// - Parameter category: The trivia category
    /// - Returns: A random team name
    static func randomTeamName(for category: TriviaCategory) -> String {
        let availableNames = category.teamNames
        return availableNames.randomElement() ?? "Team"
    }
}
