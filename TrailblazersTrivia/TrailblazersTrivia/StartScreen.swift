//
//  ContentView.swift
//  TrailblazersTrivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

// Home screen theme matching the game screen
private enum HomeTheme {
    static let background = Color(white: 0.04)      // same deep dark background
    static let card = Color(white: 0.10)            // same dark card background
    static let lightCard = Color(white: 0.16)       // same lighter card for selections
    static let text = Color(white: 1.0)             // pure white text
    static let accent = Color(white: 0.22)          // dark accent
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0) // #FFD700 bright gold
}

struct StartScreen: View {
    @State private var path: [Routes] = []
    @State private var selectedPlayerMode: PlayerMode = .onePlayer
    @State private var selectedCategory: TriviaCategory = .bible

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                HomeTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    categorySelectionView
                    playerModeSelector
                    Spacer()
                    startGameButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
            .navigationDestination(for: Routes.self) { route in
                navigationDestination(for: route)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("Trailblazers Trivia")
                .font(.largeTitle).fontWeight(.semibold)
                .foregroundColor(HomeTheme.text)
            
            Spacer()
            
            settingsButton
        }
        .padding(.bottom, 20)
    }
    
    private var settingsButton: some View {
        HStack(spacing: 8) {

            
            // Settings button
            NavigationLink(value: Routes.about) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(HomeTheme.text.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(HomeTheme.card))
                    .overlay(Circle().stroke(HomeTheme.text.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Category Selection
    private var categorySelectionView: some View {
        VStack(spacing: 12) {
            ForEach(TriviaCategory.allCases, id: \.self) { category in
                categoryCard(for: category)
            }
        }
    }
    
    private func categoryCard(for category: TriviaCategory) -> some View {
        Button {
            selectedCategory = category
        } label: {
            HStack(spacing: 16) {
                categoryIcon(for: category)
                categoryInfo(for: category)
                Spacer()
                categoryCheckmark(for: category)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
        .background(categoryCardBackground(for: category))
        .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .scaleEffect(selectedCategory == category ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: selectedCategory)
    }
    
    private func categoryIcon(for category: TriviaCategory) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(selectedCategory == category ? HomeTheme.gold : HomeTheme.text)
                .frame(width: 44, height: 44)
            
            Image(systemName: category.iconName)
                .font(.system(size: 20))
                .foregroundColor(.black)
        }
    }
    
    private func categoryInfo(for category: TriviaCategory) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(category.displayName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(HomeTheme.text)
                .multilineTextAlignment(.leading)
            
            Text(category.description)
                .font(.subheadline)
                .foregroundColor(HomeTheme.text.opacity(0.7))
        }
    }
    
    private func categoryCheckmark(for category: TriviaCategory) -> some View {
        ZStack {
            Circle()
                .fill(selectedCategory == category ? HomeTheme.gold : HomeTheme.text.opacity(0.2))
                .frame(width: 24, height: 24)
            
            if selectedCategory == category {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
    
    private func categoryCardBackground(for category: TriviaCategory) -> some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(HomeTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        selectedCategory == category 
                        ? AnyShapeStyle(HomeTheme.gold.opacity(0.5))
                        : AnyShapeStyle(LinearGradient(
                            colors: [HomeTheme.text.opacity(0.12), HomeTheme.text.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )),
                        lineWidth: selectedCategory == category ? 2 : 1
                    )
            )
    }
    
    // MARK: - Player Mode Selector
    private var playerModeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                singlePlayerButton
                teamPlayerButton
            }
            .background(playerModeSelectorBackground)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
        }
        .padding(.top, 20)
    }
    
    private var singlePlayerButton: some View {
        Button {
            selectedPlayerMode = .onePlayer
        } label: {
            Text("Single Player")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(selectedPlayerMode == .onePlayer ? .black.opacity(0.9) : HomeTheme.text.opacity(0.8))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(selectedPlayerMode == .onePlayer ? HomeTheme.gold : Color.clear)
                )
                .padding(.horizontal, 4)
        }
    }
    
    private var teamPlayerButton: some View {
        Button {
            selectedPlayerMode = .twoPlayer
        } label: {
            Text("Teams")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(selectedPlayerMode == .twoPlayer ? .black.opacity(0.9) : HomeTheme.text.opacity(0.8))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(selectedPlayerMode == .twoPlayer ? HomeTheme.gold : Color.clear)
                )
                .padding(.horizontal, 4)
        }
    }
    
    private var playerModeSelectorBackground: some View {
        Capsule()
            .fill(HomeTheme.lightCard)
            .overlay(
                Capsule()
                    .stroke(HomeTheme.text.opacity(0.1), lineWidth: 1)
            )
    }
    
    // MARK: - Start Game Button
    private var startGameButton: some View {
        NavigationLink(value: selectedPlayerMode == .onePlayer ? Routes.gameOnePlayer(category: selectedCategory) : Routes.gameTwoPlayer(category: selectedCategory)) {
            Text("Start New Game")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(HomeTheme.gold)
                )
                .shadow(color: HomeTheme.gold.opacity(0.35), radius: 10, x: 0, y: 4)
        }
    }
    
    // MARK: - Navigation
    @ViewBuilder
    private func navigationDestination(for route: Routes) -> some View {
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



#Preview {
    StartScreen()
}
