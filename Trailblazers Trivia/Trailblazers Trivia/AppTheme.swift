//
//  AppTheme.swift
//  Trailblazers Trivia
//
//  Created by Assistant on 10/19/25.
//

import SwiftUI

/// Centralized color theme for the app
extension Color {
    static let appBackground = Color(red: 0.06, green: 0.07, blue: 0.09) // #0F1218 approx
    static let cardBackground = Color(red: 0.14, green: 0.16, blue: 0.20) // #242833 approx
    static let lightCardBackground = Color(red: 0.18, green: 0.20, blue: 0.24) // Slightly lighter gray
    static let correctGreen = Color(red: 0.4, green: 0.8, blue: 0.4) // Green for correct answers
    static let coral = Color(red: 1.0, green: 0.50, blue: 0.44) // #FF7F70 approx
    static let chipBlue = Color(red: 0.35, green: 0.55, blue: 0.85) // #5A8CD8 approx
    static let controlTrack = Color(red: 0.18, green: 0.20, blue: 0.24)
}

/// Common border styles
struct AppBorders {
    static let lightBorder = Color.white.opacity(0.06)
}

/// Score formatting utilities
struct ScoreFormatter {
    /// Format a score value for display
    /// - Parameter score: The score as a Double
    /// - Returns: Formatted string representation of the score
    static func format(_ score: Double) -> String {
        // Since scores are counts of correct answers, display as whole numbers
        return "\(Int(score))"
    }
}