//
//  Trailblazers_TriviaApp.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

@main
struct TrailblazersTriviaApp: App {
    var body: some Scene {
        WindowGroup {
            StartScreen()
        }
    }
}

enum Routes: Hashable {
    case game
    case results(player1Name: String, player1Score: Int, player2Name: String, player2Score: Int, winner: String?)
}
