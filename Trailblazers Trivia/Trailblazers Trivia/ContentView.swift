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
    let isSelected: Bool
}

struct ContentView: View {
    @State private var selectedCategory: String? = "Bible"
    @State private var categories = [
        TriviaCategory(name: "Bible", icon: "book.closed", isSelected: false),
        TriviaCategory(name: "Animals", icon: "pawprint", isSelected: false),
        TriviaCategory(name: "US History", icon: "flag", isSelected: false),
        TriviaCategory(name: "World History", icon: "globe", isSelected: false),
        TriviaCategory(name: "Geography", icon: "location", isSelected: false)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient similar to the website
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header Section
                    VStack(spacing: 20) {
                        // Logo and Title
                        HStack {
                            Image(systemName: "house.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.primary)
                            
                            Text("Trailblazers Trivia")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        VStack(spacing: 15) {
                            Text("Epic Trivia Battles")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.center)
                            
                            Text("Challenge your teams • Test knowledge • Have amazing fun!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Category Selection List
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            ForEach(categories.indices, id: \.self) { index in
                                CategoryCard(
                                    category: categories[index],
                                    isSelected: selectedCategory == categories[index].name
                                ) {
                                    selectCategory(categories[index].name)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Start Game Button
                        Button(action: startNewGame) {
                            Text("Start New Game!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(LinearGradient(
                                            colors: [Color.blue.opacity(0.9), Color.blue],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ))
                                )
                        }
                        .disabled(selectedCategory == nil)
                        .opacity(selectedCategory == nil ? 0.6 : 1.0)
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func selectCategory(_ categoryName: String) {
        if selectedCategory == categoryName {
            selectedCategory = nil // Deselect if tapping the same category
        } else {
            selectedCategory = categoryName // Select new category
        }
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
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .frame(width: 30)
                
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.blue : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color.blue.opacity(0.1) : Color.white)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    ContentView()
}
