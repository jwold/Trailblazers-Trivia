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
    
    
    // MARK: - Haptics & Selection Helpers
    private func selectCategory(_ category: TriviaCategory) {
        guard selectedCategory != category else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        selectedCategory = category
    }

    private func selectMode(_ mode: PlayerMode) {
        guard selectedPlayerMode != mode else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        selectedPlayerMode = mode
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                HomeTheme.background.ignoresSafeArea()
                LinearGradient(
                    colors: [Color.white.opacity(0.06), Color.clear, Color.white.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(0.6)
                .blur(radius: 40)
                
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
                let cardWidth = min(220, max(180, geo.size.width * 0.55))
                let cardHeight = cardWidth * 0.95
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
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
            .frame(height: 210)
        }
    }

    private func categoryCarouselCard(card: CategoryCard, width: CGFloat, height: CGFloat, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(card.isEnabled ? card.accent : Color.gray.opacity(0.3))
                    .frame(width: 56, height: 56)
                Image(systemName: card.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(card.isEnabled ? .black : .gray)
            }
            Text(card.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(card.isEnabled ? HomeTheme.text : HomeTheme.text.opacity(0.4))
            Text(card.priceText)
                .font(.subheadline)
                .foregroundColor(card.isEnabled ? HomeTheme.text.opacity(0.7) : HomeTheme.text.opacity(0.3))
        }
        .padding(.vertical, 16)
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(HomeTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isSelected && card.isEnabled
                            ? AnyShapeStyle(HomeTheme.gold.opacity(0.5))
                            : AnyShapeStyle(LinearGradient(
                                colors: [HomeTheme.text.opacity(0.12), HomeTheme.text.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )),
                            lineWidth: isSelected && card.isEnabled ? 2 : 1
                        )
                )
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .opacity(0.8)
                )
        )
        .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
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
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            isSelected
                            ? AnyShapeStyle(HomeTheme.gold.opacity(0.5))
                            : AnyShapeStyle(LinearGradient(
                                colors: [HomeTheme.text.opacity(0.12), HomeTheme.text.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .opacity(0.8)
                )
        )
        .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
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
                .overlay(
                    GeometryReader { g in
                        let gradient = LinearGradient(
                            colors: [Color.white.opacity(0.0), Color.white.opacity(0.35), Color.white.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        Rectangle()
                            .fill(gradient)
                            .rotationEffect(.degrees(20))
                            .offset(x: -g.size.width)
                            .animation(.linear(duration: 1.8).repeatForever(autoreverses: false), value: UUID())
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .allowsHitTesting(false)
                )
        }
        .simultaneousGesture(TapGesture().onEnded {
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
