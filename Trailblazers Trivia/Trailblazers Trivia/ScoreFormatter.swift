//
//  ScoreFormatter.swift
//  Trailblazers Trivia
//
//  Created by Assistant on 10/19/25.
//

import Foundation

/// Utility for formatting scores consistently across the app
struct ScoreFormatter {
    /// Formats a score with fractions instead of decimals where appropriate
    /// - Parameter score: The score to format
    /// - Returns: Formatted score string (e.g., "5½" instead of "5.5")
    static func format(_ score: Double) -> String {
        let wholeNumber = Int(score)
        let remainder = score - Double(wholeNumber)
        
        if remainder == 0.5 {
            return "\(wholeNumber)½"
        } else if remainder == 0 {
            return "\(wholeNumber)"
        } else {
            // For any other fractional values, fall back to decimal
            return String(format: "%.1f", score)
        }
    }
    
    /// Formats elapsed time as MM:SS
    /// - Parameter timeInterval: The elapsed time in seconds
    /// - Returns: Formatted time string (e.g., "5:42")
    static func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}