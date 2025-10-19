//
//  Routes.swift
//  Trailblazers Trivia
//
//  Created by Assistant on 10/19/25.
//

import Foundation

enum Routes: Hashable, Identifiable {
    case gameOnePlayer
    case gameTwoPlayer
    case results(playerScores: [PlayerScore])
    case singlePlayerResults(finalScore: Double, questionsAnswered: Int, elapsedTime: TimeInterval)
    case about
    
    var id: String {
        switch self {
        case .gameOnePlayer: return "gameOnePlayer"
        case .gameTwoPlayer: return "gameTwoPlayer"
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