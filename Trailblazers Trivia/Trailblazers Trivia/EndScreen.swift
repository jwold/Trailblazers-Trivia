//
//  Results.swift
//  Trailblazers Trivia
//
//  Created by Tony Stark on 9/19/25.
//

import SwiftUI

struct EndScreen: View {
    @Binding var path: [Routes]
    let playerScores: [PlayerScore]
    
    var winner: String? {
        playerScores.first(where: { $0.isWinner })?.name
    }

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
                    ForEach(playerScores, id: \.name) { playerScore in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(playerScore.name)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                    
                                    if playerScore.isWinner {
                                        Text("🎉 WINNER")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(.green.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            Spacer()
                            Text("\(playerScore.score) points")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(playerScore.score >= 10 ? .green : .primary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(playerScore.isWinner ? .green : .clear, lineWidth: 2)
                        )
                    }
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
    EndScreen(
        path: .constant([]), 
        playerScores: [
            PlayerScore(name: "Persian", score: 10, isWinner: true),
            PlayerScore(name: "Player 2", score: 7, isWinner: false)
        ]
    )
}
