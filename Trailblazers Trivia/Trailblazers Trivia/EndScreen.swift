//
//  Results.swift
//  Trailblazers Trivia
//
//  Created by Tony Stark on 9/19/25.
//

import SwiftUI

struct EndScreen: View {
    @Binding var path: [Routes]
    let player1Name: String
    let player1Score: Int
    let player2Name: String
    let player2Score: Int
    let winner: String?

    var body: some View {
        VStack(spacing: 30) {
            // Title
            VStack(spacing: 8) {
                Text("Game Over!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let winner = winner {
                    Text("🎉 \(winner) Wins! 🎉")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                } else {
                    Text("It's a Tie!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            // Scores
            VStack(spacing: 20) {
                Text("Final Scores")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 16) {
                    // Player 1 Score
                    HStack {
                        Text(player1Name)
                            .font(.headline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(player1Score) points")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(player1Score >= 10 ? .green : .primary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(player1Name == winner ? .green : .clear, lineWidth: 2)
                    )
                    
                    // Player 2 Score
                    HStack {
                        Text(player2Name)
                            .font(.headline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(player2Score) points")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(player2Score >= 10 ? .green : .primary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(player2Name == winner ? .green : .clear, lineWidth: 2)
                    )
                }
            }
            
            Spacer()
            
            // Navigation buttons
            VStack(spacing: 16) {
                Button(action: {
                    path.removeLast(path.count)
                }) {
                    Text("Play Again")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue)
                        )
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    EndScreen(path: .constant([]), player1Name: "Persian", player1Score: 10, player2Name: "Player 2", player2Score: 7, winner: "Persian")
}
