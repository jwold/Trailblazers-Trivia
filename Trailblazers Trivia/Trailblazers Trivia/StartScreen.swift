//
//  ContentView.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold on 9/16/25.
//

import SwiftUI

struct TriviaCategory {
    let id = UUID()
    let name: String
    let icon: String
    let isAvailable: Bool
}

struct StartScreen: View {
    @State private var path: [Routes] = []

    @State private var selectedCategory: String? = "Bible"
    @State private var categories = [
        TriviaCategory(name: "Bible", icon: "book.closed", isAvailable: true),
        TriviaCategory(name: "Animals", icon: "pawprint", isAvailable: false),
        TriviaCategory(name: "US History", icon: "flag", isAvailable: false),
        TriviaCategory(name: "World History", icon: "globe", isAvailable: false),
        TriviaCategory(name: "Geography", icon: "location", isAvailable: false)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(categories.indices, id: \.self) { index in
                        CategoryCard(
                            category: categories[index],
                            isSelected: selectedCategory == categories[index].name
                        )
                        
                        if index < categories.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                
                Spacer()
                
                NavigationLink(value: Routes.game) {
                    Text("Start New Game")
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
            .navigationTitle("Trailblazers Trivia")
            .padding(.bottom, 40)
            .padding(.horizontal, 20)
            .navigationDestination(for: Routes.self) { route in
                switch route {
                case .game:
                    GameScreen(path: $path)
                case .results:
                    EndScreen(path: $path)
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
                        .fill(isSelected ? Color.black : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(category.isAvailable ? .black : .gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Right side content
                if category.isAvailable {
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                } else {
                    Text("Coming Soon")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!category.isAvailable)
    }
}

#Preview {
    StartScreen()
}
