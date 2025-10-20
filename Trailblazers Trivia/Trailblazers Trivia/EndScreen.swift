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
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header (no card)
                VStack(alignment: .leading, spacing: 12) {
                    EmptyView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)

                // Scores card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Final Scores")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.labelPrimary)
                    VStack(spacing: 12) {
                        ForEach(playerScores, id: \.name) { playerScore in
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text(playerScore.name)
                                            .font(.headline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Color.labelPrimary)
                                        if playerScore.isWinner {
                                            Text("WINNER")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black.opacity(0.85))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Capsule().fill(Color.chipBlue))
                                                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                                        }
                                    }
                                }
                                Spacer()
                                Text("\(ScoreFormatter.format(playerScore.score)) points")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.labelPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.12), .white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                .padding(.top, 20)

                Spacer()
            }
            .padding(.horizontal, 20)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 16) {
                    Button(action: {
                        path.removeLast(path.count)
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.chipBlue)
                            )
                            .shadow(color: Color.chipBlue.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .background(Color.appBackground)
                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: -2)
            }
        }
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

