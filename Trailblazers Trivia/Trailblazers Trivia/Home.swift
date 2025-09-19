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

struct Home: View {
    @State private var selectedCategory: String? = "Bible"
    @State private var categories = [
        TriviaCategory(name: "Bible", icon: "book.closed", isAvailable: true),
        TriviaCategory(name: "Animals", icon: "pawprint", isAvailable: false),
        TriviaCategory(name: "US History", icon: "flag", isAvailable: false),
        TriviaCategory(name: "World History", icon: "globe", isAvailable: false),
        TriviaCategory(name: "Geography", icon: "location", isAvailable: false)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title
                    HStack {
                        Text("Trailblazers Trivia")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    
                    // Category List
                    VStack(spacing: 0) {
                        ForEach(categories.indices, id: \.self) { index in
                            CategoryCard(
                                category: categories[index],
                                isSelected: selectedCategory == categories[index].name
                            ) {
                                if categories[index].isAvailable {
                                    selectCategory(categories[index].name)
                                }
                            }
                            
                            if index < categories.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Start Game Button
                    Button(action: startNewGame) {
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
                    .disabled(selectedCategory == nil)
                    .opacity(selectedCategory == nil ? 0.6 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func selectCategory(_ categoryName: String) {
        selectedCategory = categoryName
    }
    
    private func startNewGame() {
        // Implement game start logic here
        if let category = selectedCategory {
            print("Starting new game with category: \(category)")
        }
    }
}

struct CategoryCard: View {
    let category: TriviaCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
    Home()
}
