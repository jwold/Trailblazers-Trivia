//
//  Trailblazers_TriviaApp.swift
//  TrailblazersTrivia
//
//  Created by Joshua Wold and Nathan Isaac on 9/16/25.
//

import SwiftUI
import RevenueCat

@main
struct TrailblazersTriviaApp: App {
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.revenueCatAPIKey)
    }

    var body: some Scene {
        WindowGroup {
            StartScreen()
        }
    }
}
