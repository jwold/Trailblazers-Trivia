//
//  TickerTapeScore.swift
//  TrailblazersTrivia
//
//  Created by Joshua Wold and Nathan Isaac on 11/19/25.
//

import SwiftUI

/// A ticker tape-style animated score display that smoothly transitions when the score changes
struct TickerTapeScore: View {
    let score: Double
    let font: Font
    let fontWeight: Font.Weight
    let foregroundColor: Color
    
    @State private var displayedScore: Double = 0
    @State private var isAnimating = false
    
    init(
        score: Double,
        font: Font = .subheadline,
        fontWeight: Font.Weight = .bold,
        foregroundColor: Color = .white
    ) {
        self.score = score
        self.font = font
        self.fontWeight = fontWeight
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        Text(ScoreFormatter.format(displayedScore))
            .font(font)
            .fontWeight(fontWeight)
            .foregroundColor(foregroundColor)
            .contentTransition(.numericText(value: displayedScore))
            .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3), value: displayedScore)
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.1), value: isAnimating)
            .onChange(of: score) { oldValue, newValue in
                animateScoreChange(from: oldValue, to: newValue)
            }
            .onAppear {
                // Initialize displayed score to current score
                displayedScore = score
            }
    }
    
    private func animateScoreChange(from oldScore: Double, to newScore: Double) {
        // Trigger scale animation
        isAnimating = true
        
        // Animate the score counting up
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            displayedScore = newScore
        }
        
        // Reset scale after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isAnimating = false
        }
    }
}

#Preview("Ticker Tape Score - Light") {
    VStack(spacing: 40) {
        TickerTapeScoreDemo()
    }
    .padding()
    .background(Color(white: 0.04))
}

// MARK: - Preview Demo

private struct TickerTapeScoreDemo: View {
    @State private var score: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Ticker Tape Score Demo")
                .font(.title)
                .foregroundColor(.white)
            
            // Demo score display
            HStack(spacing: 8) {
                Text("Score:")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                TickerTapeScore(
                    score: score,
                    font: .largeTitle,
                    fontWeight: .bold,
                    foregroundColor: Color(red: 0.35, green: 0.55, blue: 0.77)
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.10))
            )
            
            // Control buttons
            VStack(spacing: 16) {
                Button("Add 1 Point") {
                    score += 1
                }
                .buttonStyle(.borderedProminent)
                
                Button("Add 5 Points") {
                    score += 5
                }
                .buttonStyle(.bordered)
                
                Button("Reset") {
                    score = 0
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
