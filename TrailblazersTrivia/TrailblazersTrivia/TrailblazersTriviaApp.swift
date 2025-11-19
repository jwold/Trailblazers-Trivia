//
//  Trailblazers_TriviaApp.swift
//  TrailblazersTrivia
//
//  Created by Joshua Wold and Nathan Isaac on 9/16/25.
//

import SwiftUI
// Commented out RevenueCat for now
// import RevenueCat

@main
struct TrailblazersTriviaApp: App {
    init() {
        // Commented out RevenueCat - Completely defer RevenueCat - it can wait
//        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) {
//            print("📦 Starting RevenueCat configuration at \(Date())")
//            Purchases.logLevel = .debug
//            Purchases.configure(withAPIKey: Config.revenueCatAPIKey)
//            print("✅ RevenueCat configuration completed at \(Date())")
//        }
    }

    var body: some Scene {
        WindowGroup {
            StartScreen()
        }
    }
}
