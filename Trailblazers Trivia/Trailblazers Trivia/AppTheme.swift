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
    static let extraLightCardBackground = Color(red: 0.25, green: 0.28, blue: 0.32) // Even lighter gray for chips
    static let chipBlue = Color(red: 0.35, green: 0.55, blue: 0.85) // #5A8CD8 approx
    static let coral = Color(red: 1.0, green: 0.50, blue: 0.44) // #FF7F70 approx
    static let correctGreen = Color(red: 0.4, green: 0.8, blue: 0.4) // Green for correct answers
    static let controlTrack = Color(red: 0.18, green: 0.20, blue: 0.24)
    static let controlShadow = Color.black.opacity(0.5)
    static let labelPrimary = Color(red: 0.75, green: 0.77, blue: 0.83) // #BEC3D4
}

/// Common border styles
struct AppBorders {
    static let cardBorder = LinearGradient(
        colors: [.white.opacity(0.12), .white.opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let lightBorder = Color.white.opacity(0.06)
}