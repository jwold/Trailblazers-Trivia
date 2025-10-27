//
//  Routes.swift
//  Trailblazers Trivia
//
//  Created by Assistant on 10/19/25.
//

import Foundation

struct PlayerScore: Hashable {
    let name: String
    let score: Double
    let isWinner: Bool
}

enum Routes: Hashable, Identifiable {
    case gameOnePlayer(category: TriviaCategory)
    case gameTwoPlayer(category: TriviaCategory)
    case results(playerScores: [PlayerScore])
    case singlePlayerResults(finalScore: Double, questionsAnswered: Int, elapsedTime: TimeInterval)
    case about
    
    var id: String {
        switch self {
        case .gameOnePlayer(let category): return "gameOnePlayer_\(category.rawValue)"
        case .gameTwoPlayer(let category): return "gameTwoPlayer_\(category.rawValue)"
        case .results: return "results"
        case .singlePlayerResults: return "singlePlayerResults"
        case .about: return "about"
        }
    }
    
    var playerMode: PlayerMode? {
        switch self {
        case .gameOnePlayer: return .onePlayer
        case .gameTwoPlayer: return .twoPlayer
        default: return nil
        }
    }
}

enum PlayerMode: Hashable {
    case onePlayer, twoPlayer
    
    var displayName: String {
        switch self {
        case .onePlayer: return "1 Player"
        case .twoPlayer: return "2 Players"
        }
    }
}
