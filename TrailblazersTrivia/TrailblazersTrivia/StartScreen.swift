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
    static let gold = Color(red: 0.35, green: 0.55, blue: 0.77) // #5A8BC4 blue
}

struct StartScreen: View {
    @State private var path: [Routes] = []
    @State private var selectedPlayerMode: PlayerMode = .onePlayer
    @State private var selectedCategory: TriviaCategory = .bible
    
    // Prepare haptic generator once for better performance
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    init() {
        print("🎮 StartScreen init at \(Date())")
    }
    
    // MARK: - Haptics & Selection Helpers
    private func selectCategory(_ category: TriviaCategory) {
        guard selectedCategory != category else { return }
        print("📂 Category selected: \(category) at \(Date())")
        impactGenerator.impactOccurred()
        selectedCategory = category
    }

    private func selectMode(_ mode: PlayerMode) {
        guard selectedPlayerMode != mode else { return }
        print("🎯 Mode selected: \(mode) at \(Date())")
        impactGenerator.impactOccurred()
        selectedPlayerMode = mode
    }

    var body: some View {
        let _ = print("🎨 StartScreen body evaluation at \(Date())")
        
        NavigationStack(path: $path) {
            ZStack {
                HomeTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    categoryCarousel
                    playerModeCards
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
            .onAppear {
                print("👀 StartScreen onAppear at \(Date())")
                // Prepare haptic generator for immediate response
                impactGenerator.prepare()
                print("✅ Haptic generator prepared at \(Date())")
                
                // Test if main thread is responsive
                DispatchQueue.main.async {
                    print("✅ Main thread responsive at \(Date())")
                }
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
    
    // MARK: - Category Carousel
    private struct CategoryCard: Identifiable {
        let id = UUID()
        let iconName: String
        let title: String
        let priceText: String
        let mappedCategory: TriviaCategory
        let accent: Color
        let isEnabled: Bool
    }

    private var categoryCards: [CategoryCard] {
        [
            CategoryCard(iconName: "book.fill", title: "Bible", priceText: "Free", mappedCategory: .bible, accent: .teal, isEnabled: true),
            CategoryCard(iconName: "flag.fill", title: "US History", priceText: "Free", mappedCategory: .usHistory, accent: .red, isEnabled: true),
            CategoryCard(iconName: "pawprint.fill", title: "Animals", priceText: "Coming Soon", mappedCategory: .bible, accent: .pink, isEnabled: false),
            CategoryCard(iconName: "map.fill", title: "Geography", priceText: "Coming Soon", mappedCategory: .bible, accent: .purple, isEnabled: false)
        ]
    }

    private var categoryCarousel: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                // Reduced by 25%: was 0.55, now 0.4125 (0.55 * 0.75)
                let cardWidth = min(165, max(135, geo.size.width * 0.4125))
                let cardHeight = cardWidth * 0.95
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) { // Reduced spacing from 16 to 12
                            ForEach(categoryCards) { card in
                                categoryCarouselCard(card: card, width: cardWidth, height: cardHeight, isSelected: selectedCategory == card.mappedCategory)
                                    .id(card.id)
                                    .onTapGesture { 
                                        if card.isEnabled {
                                            selectCategory(card.mappedCategory)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 2)
                    }
                    .onAppear {
                        if let first = categoryCards.first { proxy.scrollTo(first.id, anchor: .leading) }
                    }
                }
            }
            .frame(height: 158) // Reduced by 25%: was 210, now 158 (210 * 0.75)
        }
    }

    private func categoryCarouselCard(card: CategoryCard, width: CGFloat, height: CGFloat, isSelected: Bool) -> some View {
        VStack(spacing: 6) { // Reduced from 8 to 6
            ZStack {
                RoundedRectangle(cornerRadius: 10) // Reduced from 14 to 10
                    .fill(card.isEnabled ? card.accent : Color.gray.opacity(0.3))
                    .frame(width: 42, height: 42) // Reduced from 56 to 42 (25% smaller)
                Image(systemName: card.iconName)
                    .font(.system(size: 18, weight: .semibold)) // Reduced from 24 to 18
                    .foregroundColor(card.isEnabled ? .black : .gray)
            }
            Text(card.title)
                .font(.subheadline) // Reduced from .headline to .subheadline
                .fontWeight(.semibold)
                .foregroundColor(card.isEnabled ? HomeTheme.text : HomeTheme.text.opacity(0.4))
            Text(card.priceText)
                .font(.caption) // Reduced from .subheadline to .caption
                .foregroundColor(card.isEnabled ? HomeTheme.text.opacity(0.7) : HomeTheme.text.opacity(0.3))
        }
        .padding(.vertical, 12) // Reduced from 16 to 12
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: 15) // Reduced from 20 to 15
                .fill(HomeTheme.card)
                .stroke(isSelected && card.isEnabled ? HomeTheme.gold : HomeTheme.text.opacity(0.1), lineWidth: isSelected && card.isEnabled ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3) // Reduced shadow from radius 8 to 6
        .scaleEffect(isSelected && card.isEnabled ? 1.02 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: isSelected)
        .opacity(card.isEnabled ? 1.0 : 0.5)
    }
    
    // MARK: - Player Mode Cards
    private struct PlayerModeOption {
        let mode: PlayerMode
        let iconName: String
        let title: String
        let subtitle: String
        let accent: Color
    }
    
    private var playerModeOptions: [PlayerModeOption] {
        [
            PlayerModeOption(
                mode: .onePlayer,
                iconName: "person.fill",
                title: "Just me",
                subtitle: "Play solo and test your knowledge.",
                accent: Color.teal
            ),
            PlayerModeOption(
                mode: .couchMode,
                iconName: "person.2.fill",
                title: "Couch Mode",
                subtitle: "Take turns passing the device back and forth.",
                accent: Color.purple
            ),
            PlayerModeOption(
                mode: .twoPlayer,
                iconName: "megaphone.fill",
                title: "Shout Out Mode",
                subtitle: "First to answer out loud scores the point.",
                accent: Color.pink
            )
        ]
    }
    
    private var playerModeCards: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 12) {
                ForEach(playerModeOptions, id: \.title) { option in
                    playerModeCard(option: option, isSelected: selectedPlayerMode == option.mode)
                        .onTapGesture { selectMode(option.mode) }
                }
            }
            .padding(.top, 0)
        }
        .padding(.top, 24)
    }
    
    private func playerModeCard(option: PlayerModeOption, isSelected: Bool) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(option.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(HomeTheme.text)
                Text(option.subtitle)
                    .font(.subheadline)
                    .foregroundColor(HomeTheme.text.opacity(0.7))
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(isSelected ? HomeTheme.gold : HomeTheme.text.opacity(0.2))
                    .frame(width: 24, height: 24)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(HomeTheme.card)
                .stroke(isSelected ? HomeTheme.gold : HomeTheme.text.opacity(0.1), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: isSelected)
    }
    
    // MARK: - Start Game Button
    private var startGameButton: some View {
        let destination: Routes
        switch selectedPlayerMode {
        case .onePlayer:
            destination = .gameOnePlayer(category: selectedCategory)
        case .twoPlayer:
            destination = .gameTwoPlayer(category: selectedCategory)
        case .couchMode:
            destination = .gameCouchMode(category: selectedCategory)
        }
        
        return NavigationLink(value: destination) {
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
        .simultaneousGesture(TapGesture().onEnded {
            print("🎮 Start Game button tapped at \(Date())")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        })
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
