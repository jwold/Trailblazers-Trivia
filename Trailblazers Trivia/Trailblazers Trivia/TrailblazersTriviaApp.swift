//
//  Trailblazers_TriviaApp.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold and Nathan Isaac on 9/16/25.
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
    case results(playerScores: [PlayerScore])
    case about
}
