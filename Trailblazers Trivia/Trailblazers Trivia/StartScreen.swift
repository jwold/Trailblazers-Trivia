//
//  ContentView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

private extension Color {
    static let appBackground = Color(red: 0.06, green: 0.07, blue: 0.09) // #0F1218 approx
    static let cardBackground = Color(red: 0.14, green: 0.16, blue: 0.20) // #242833 approx
    static let chipBlue = Color(red: 0.35, green: 0.55, blue: 0.85) // #5A8CD8 approx
    static let labelPrimary = Color(red: 0.75, green: 0.77, blue: 0.83) // #BEC3D4
}

struct TriviaCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let isAvailable: Bool
}

struct StartScreen: View {
    @State private var path: [Routes] = []

    @State private var selectedCategory: String? = "Bible"
    @State private var selectedPlayerMode: PlayerMode = .twoPlayer
    @State private var categories = [
        TriviaCategory(name: "Bible", icon: "book.closed", isAvailable: true),
        TriviaCategory(name: "Animals", icon: "pawprint", isAvailable: false),
        TriviaCategory(name: "US History", icon: "flag", isAvailable: false),
        TriviaCategory(name: "World History", icon: "globe", isAvailable: false),
        TriviaCategory(name: "Geography", icon: "location", isAvailable: false)
    ]



    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Trailblazers Trivia")
                            .font(.largeTitle).fontWeight(.semibold)
                            .foregroundColor(Color.labelPrimary)
                        
                        Spacer()
                        
                        NavigationLink(value: Routes.about) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundColor(Color.labelPrimary.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle().fill(Color.cardBackground)
                                )
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 0) {
                        ForEach(categories) { category in
                            CategoryCard(
                                category: category,
                                isSelected: selectedCategory == category.name
                            )
                            
                            if category.id != categories.last?.id {
                                Divider()
                            }
                        }
                    }
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                    
                    // Player Mode Switcher
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 0) {
                            // Two Player Button
                            Button {
                                selectedPlayerMode = .twoPlayer
                            } label: {
                                Text("2 Players")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedPlayerMode == .twoPlayer ? .black.opacity(0.9) : Color.labelPrimary.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        Capsule()
                                            .fill(selectedPlayerMode == .twoPlayer ? Color.chipBlue : Color.clear)
                                    )
                                    .padding(.horizontal, 4)
                            }
                            
                            // One Player Button
                            Button {
                                selectedPlayerMode = .onePlayer
                            } label: {
                                Text("1 Player")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedPlayerMode == .onePlayer ? .black.opacity(0.9) : Color.labelPrimary.opacity(0.8))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        Capsule()
                                            .fill(selectedPlayerMode == .onePlayer ? Color.chipBlue : Color.clear)
                                    )
                                    .padding(.horizontal, 4)
                            }
                        }
                        .background(
                            Capsule()
                                .fill(Color.cardBackground)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    NavigationLink(value: selectedPlayerMode == .onePlayer ? Routes.gameOnePlayer : Routes.gameTwoPlayer) {
                        Text("Start New Game")
                            .font(.title2)
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
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
            .navigationDestination(for: Routes.self) { route in
                switch route {
                case .gameOnePlayer:
                    SinglePlayerGameScreen(path: $path)
                case .gameTwoPlayer:
                    GameScreen(path: $path)
                case .results(let playerScores):
                    EndScreen(path: $path, playerScores: playerScores)
                case .singlePlayerResults(let finalScore, let questionsAnswered, let elapsedTime):
                    SinglePlayerEndScreen(path: $path, finalScore: finalScore, questionsAnswered: questionsAnswered, elapsedTime: elapsedTime)
                case .about:
                    AboutScreen(path: $path)
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: TriviaCategory
    let isSelected: Bool
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Icon with dark background for selected, light for others
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.white : Color.white.opacity(0.06))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .black : .secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(category.isAvailable ? Color.labelPrimary : Color.labelPrimary.opacity(0.6))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Right side content
                if category.isAvailable {
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(Color.chipBlue)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                } else {
                    Text("Coming Soon")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.labelPrimary.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!category.isAvailable)
    }
}

#Preview {
    StartScreen()
}
