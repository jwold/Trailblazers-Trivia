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
    static let inactiveCard = Color(white: 0.08)    // very subtle card for inactive categories
    static let lightCard = Color(white: 0.16)       // same lighter card for selections
    static let text = Color(white: 1.0)             // pure white text
    static let accent = Color(white: 0.22)          // dark accent
    static let selectedCard = Color(white: 0.20)    // selected state
    static let blue = Color(red: 0.35, green: 0.55, blue: 0.77) // #5A8BC4 blue
    static let blueGradientStart = Color(red: 0.40, green: 0.60, blue: 0.82) // Lighter blue
    static let blueGradientEnd = Color(red: 0.30, green: 0.50, blue: 0.72) // Darker blue
}

// Extended categories including disabled ones
enum CategoryOption: String, CaseIterable {
    case bible = "Bible"
    case usHistory = "US History"
    case geography = "Geography"
    case worldHistory = "World History"
    case animals = "Animals"
    
    var isEnabled: Bool {
        switch self {
        case .bible, .usHistory, .animals:
            return true
        case .geography, .worldHistory:
            return false
        }
    }
    
    var triviaCategory: TriviaCategory? {
        switch self {
        case .bible: return .bible
        case .usHistory: return .usHistory
        case .animals: return .animals
        default: return nil
        }
    }
}

struct StartScreen: View {
    @State private var path: [Routes] = []
    @State private var selectedCategory: CategoryOption = .bible
    @State private var selectedPlayerMode: PlayerMode = .onePlayer
    @State private var showAboutModal = false
    
    // Prepare haptic generator once for better performance
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                HomeTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                        .padding(.top, 40)
                    
                    Spacer().frame(height: 40)
                    
                    categoryList
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(for: Routes.self) { route in
                navigationDestination(for: route)
            }
            .sheet(isPresented: $showAboutModal) {
                UnifiedInfoModalView()
            }
            .onAppear {
                impactGenerator.prepare()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // App title
            Text("Trailblazers Trivia")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(HomeTheme.text)
            
            Spacer()
            
            settingsButton
        }
    }
    
    private var settingsButton: some View {
        Button {
            showAboutModal = true
        } label: {
            Image(systemName: "info.circle")
                .font(.headline)
                .foregroundColor(HomeTheme.text.opacity(0.7))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Category List
    
    private var categoryList: some View {
        VStack(spacing: 16) {
            ForEach(CategoryOption.allCases.filter { $0.isEnabled }, id: \.self) { category in
                categoryRow(category)
            }
        }
    }
    
    private func categoryRow(_ category: CategoryOption) -> some View {
        Button {
            handleCategoryTap(category)
        } label: {
            VStack(spacing: 0) {
                if selectedCategory == category && category.isEnabled {
                    // Selected active category - full card with controls
                    VStack(alignment: .leading, spacing: 20) {
                        // Category name
                        Text(category.rawValue)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(HomeTheme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Player mode selector - spanning full width
                        playerModeSelectorFullWidth
                        
                        // Start Game button
                        startGameButtonLarge
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(HomeTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(HomeTheme.text.opacity(0.15), lineWidth: 1)
                            )
                    )
                } else {
                    // Non-selected category - minimal card
                    HStack {
                        Text(category.rawValue)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(category.isEnabled ? HomeTheme.text : HomeTheme.text.opacity(0.3))
                        
                        Spacer()
                        
                        if !category.isEnabled {
                            Text("COMING SOON")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(HomeTheme.text.opacity(0.4))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(HomeTheme.text.opacity(0.08))
                                )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(HomeTheme.inactiveCard)
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!category.isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleCategoryTap(_ category: CategoryOption) {
        guard category.isEnabled else { return }
        
        impactGenerator.impactOccurred()
        
        // Only select, don't start game on second tap anymore
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedCategory = category
        }
    }
    
    // MARK: - Player Mode Selector (Full Width)
    
    private var playerModeSelectorFullWidth: some View {
        HStack(spacing: 0) {
            playerModeOptionFullWidth(.onePlayer, title: "1P")
            playerModeOptionFullWidth(.couchMode, title: "2P")
            playerModeOptionFullWidth(.twoPlayer, title: "Group")
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
    }
    
    private func playerModeOptionFullWidth(_ mode: PlayerMode, title: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedPlayerMode = mode
            }
            impactGenerator.impactOccurred()
        } label: {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(selectedPlayerMode == mode ? HomeTheme.text : HomeTheme.text.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedPlayerMode == mode ? HomeTheme.lightCard : Color.clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var startGameButtonLarge: some View {
        Button {
            startGame()
        } label: {
            Text("Start Game")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [HomeTheme.blueGradientStart, HomeTheme.blueGradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Player Mode Selector (Old - Keep for compatibility)
    
    private var playerModeSelector: some View {
        HStack(spacing: 0) {
            playerModeOption(.onePlayer, title: "1P")
            playerModeOption(.couchMode, title: "2P")
            playerModeOption(.twoPlayer, title: "Group")
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(HomeTheme.card)
        )
    }
    
    private var startGameButton: some View {
        Button {
            startGame()
        } label: {
            Text("Start")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 40) // Match height with mode selector
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(red: 0.35, green: 0.55, blue: 0.77)) // #5A8BC4 blue
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func playerModeOption(_ mode: PlayerMode, title: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1)) {
                selectedPlayerMode = mode
            }
            impactGenerator.impactOccurred()
        } label: {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(selectedPlayerMode == mode ? HomeTheme.text : HomeTheme.text.opacity(0.6))
                .frame(maxWidth: .infinity)
                .frame(height: 34) // Fixed height for consistency
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedPlayerMode == mode ? HomeTheme.lightCard : Color.clear)
                )
                .contentShape(Rectangle()) // Make entire frame tappable
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Start Game
    
    private func startGame() {
        guard let category = selectedCategory.triviaCategory else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let route: Routes
        switch selectedPlayerMode {
        case .onePlayer:
            route = .gameOnePlayer(category: category)
        case .twoPlayer:
            route = .gameTwoPlayer(category: category)
        case .couchMode:
            route = .gameCouchMode(category: category)
        }
        
        path.append(route)
    }
    
    // MARK: - Navigation
    
    @ViewBuilder
    private func navigationDestination(for route: Routes) -> some View {
        switch route {
        case .gameOnePlayer(let category):
            SinglePlayerGameScreen(path: $path, category: category)
        case .gameTwoPlayer(let category):
            GameScreen(path: $path, category: category)
        case .gameCouchMode(let category):
            CouchModeGameScreen(path: $path, category: category)
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
