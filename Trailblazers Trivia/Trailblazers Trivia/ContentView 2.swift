import SwiftUI

// This file provides a minimal, conflict-free home screen so the app can build and load the first page again.
// All types are uniquely prefixed with `Home` to avoid clashes with similarly named types elsewhere in the project.

private struct HomeCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let filename: String
}

private struct HomeHeaderView: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "house.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                Text("Trailblazers Trivia")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.bottom)

            Text("Epic Trivia Battles")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)

            Text("Challenge your teams • Test knowledge • Have amazing fun!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
}

private struct HomeCategoryCard: View {
    let category: HomeCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .primary)
                    .frame(width: 32)

                Text(category.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding()
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

// Renamed to `HomeView` to avoid clashes with any other `ContentView` in the project.
struct HomeView: View {
    @State private var selectedCategoryName: String? = "Bible"

    private let categories: [HomeCategory] = [
        HomeCategory(name: "Bible", icon: "book.closed", filename: "bible"),
        HomeCategory(name: "Animals", icon: "pawprint", filename: "animals"),
        HomeCategory(name: "US History", icon: "flag", filename: "us_history"),
        HomeCategory(name: "World History", icon: "globe", filename: "world_history"),
        HomeCategory(name: "Geography", icon: "location", filename: "geography")
    ]

    var body: some View {
        NavigationStack {
            VStack {
                HomeHeaderView()

                Spacer()

                VStack {
                    LazyVStack(spacing: 8) {
                        ForEach(categories) { category in
                            HomeCategoryCard(
                                category: category,
                                isSelected: selectedCategoryName == category.name
                            ) {
                                selectCategory(category.name)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)

                    // The Start button is kept but does not navigate/present anything yet,
                    // to keep this file self-contained and conflict-free.
                    Button(action: {}) {
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
                    .disabled(selectedCategoryName == nil)
                    .opacity(selectedCategoryName == nil ? 0.6 : 1.0)
                    .padding(.horizontal)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 8)
                )
                .padding()

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(systemName: "house.circle.fill")
                            .font(.title2)
                        Text("Trailblazers Trivia")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    private func selectCategory(_ categoryName: String) {
        if selectedCategoryName == categoryName {
            selectedCategoryName = nil
        } else {
            selectedCategoryName = categoryName
        }
    }
}

#Preview {
    HomeView()
}
