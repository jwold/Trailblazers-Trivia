//
//  ContentView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI


struct StartScreen: View {
    @State private var path: [Routes] = []
    @State private var selectedPlayerMode: PlayerMode = .onePlayer
    @State private var selectedCategory: TriviaCategory = .bible



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
                    
                    // Category Selection Cards
                    VStack(spacing: 12) {
                        ForEach(TriviaCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                HStack(spacing: 16) {
                                    // Icon
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: category.iconName)
                                            .font(.system(size: 20))
                                            .foregroundColor(.black)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(category.displayName)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.labelPrimary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text(category.description)
                                            .font(.subheadline)
                                            .foregroundColor(Color.labelPrimary.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    // Selected checkmark
                                    ZStack {
                                        Circle()
                                            .fill(selectedCategory == category ? Color.chipBlue : Color.labelPrimary.opacity(0.2))
                                            .frame(width: 24, height: 24)
                                        
                                        if selectedCategory == category {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .background(Color.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                        }
                    }
                    
                    // Player Mode Switcher
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 0) {
                            // One Player Button (now first)
                            Button {
                                selectedPlayerMode = .onePlayer
                            } label: {
                                Text("Single Player")
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
                            
                            // Two Player Button (now second)
                            Button {
                                selectedPlayerMode = .twoPlayer
                            } label: {
                                Text("Teams")
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
                    
                    NavigationLink(value: selectedPlayerMode == .onePlayer ? Routes.gameOnePlayer(category: selectedCategory) : Routes.gameTwoPlayer(category: selectedCategory)) {
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
                case .gameOnePlayer(let category):
                    SinglePlayerGameScreen(path: $path, category: category)
                case .gameTwoPlayer(let category):
                    GameScreen(path: $path, category: category)
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



#Preview {
    StartScreen()
}
