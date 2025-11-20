//
//  UnifiedInfoModal.swift
//  TrailblazersTrivia
//
//  Created by AI Assistant on 11/19/25.
//

import SwiftUI

private enum ModalTheme {
    static let background = Color(white: 0.04)
    static let card = Color(white: 0.10)
    static let lightCard = Color(white: 0.16)
    static let text = Color(white: 1.0)
    static let accent = Color(white: 0.22)
    static let gold = Color(red: 0.35, green: 0.55, blue: 0.77) // #5A8BC4 blue
}

// MARK: - Unified Info Modal View

struct UnifiedInfoModalView: View {
    @Environment(\.dismiss) var dismiss
    
    // Haptic feedback
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack {
            ModalTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (fixed) - just close button
                HStack {
                    Spacer()
                    Button {
                        impactLight.impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(ModalTheme.text.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(ModalTheme.card)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .background(ModalTheme.background)
                
                // Scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        // How to Play Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("How to Play")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(ModalTheme.text)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 16) {
                                // Single Player Mode
                                GameModeCard(
                                    icon: "person.fill",
                                    title: "Single Player",
                                    description: "Test your knowledge solo with multiple choice questions.",
                                    instructions: [
                                        "Select answers from 4 options",
                                        "Results show immediately",
                                        "Reach 10 points or answer 20 questions"
                                    ]
                                )
                                
                                // 2 Player Mode
                                GameModeCard(
                                    icon: "person.2.fill",
                                    title: "2 Player",
                                    description: "Two players take turns on the same device.",
                                    instructions: [
                                        "Current player reads and answers",
                                        "Pass device after each question",
                                        "First to 10 points wins"
                                    ]
                                )
                                
                                // Group Mode
                                GameModeCard(
                                    icon: "megaphone.fill",
                                    title: "Group",
                                    description: "Group setting with two teams competing.",
                                    instructions: [
                                        "Read question to both teams",
                                        "First team to shout wins the turn",
                                        "Award points for correct answers"
                                    ]
                                )
                            }
                        }
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("About the App")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(ModalTheme.text)
                                .padding(.horizontal, 24)
                            
                            VStack(alignment: .leading, spacing: 24) {
                                // App description
                                Text("Test your knowledge with challenging trivia questions across various categories. Perfect for Bible study groups, classrooms, or friendly competition.")
                                    .font(.body)
                                    .foregroundColor(ModalTheme.text.opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Divider()
                                    .background(ModalTheme.text.opacity(0.1))
                                
                                // Creators
                                Text("Created by Joshua Wold and Nathan Isaac.")
                                    .font(.body)
                                    .foregroundColor(ModalTheme.text.opacity(0.8))
                                
                                Divider()
                                    .background(ModalTheme.text.opacity(0.1))
                                
                                // Contact
                                Text("Got questions? Please reach out with any feedback to trailblazerstrivia@gmail.com.")
                                    .font(.body)
                                    .foregroundColor(ModalTheme.text.opacity(0.8))
                                
                                Divider()
                                    .background(ModalTheme.text.opacity(0.1))
                                
                                // Version
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("App Version")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(ModalTheme.text)
                                    
                                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                                       let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                                        Text("Version \(version) (Build \(build))")
                                            .font(.subheadline)
                                            .foregroundColor(ModalTheme.text.opacity(0.6))
                                    } else {
                                        Text("Version 1.0")
                                            .font(.subheadline)
                                            .foregroundColor(ModalTheme.text.opacity(0.6))
                                    }
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(ModalTheme.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [ModalTheme.text.opacity(0.12), ModalTheme.text.opacity(0.04)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 120) // Extra space for button
                }
                
                // Close button (fixed at bottom)
                VStack {
                    Button {
                        impactLight.impactOccurred()
                        dismiss()
                    } label: {
                        Text("Got it!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(ModalTheme.gold)
                            )
                            .shadow(color: ModalTheme.gold.opacity(0.35), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .padding(.top, 16)
                }
                .background(
                    LinearGradient(
                        colors: [ModalTheme.background.opacity(0), ModalTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .offset(y: -100)
                )
                .background(ModalTheme.background)
            }
        }
        .onAppear {
            impactLight.prepare()
        }
    }
}

// MARK: - Game Mode Card

struct GameModeCard: View {
    let icon: String
    let title: String
    let description: String
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header - title only, no icon
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(ModalTheme.text)
            
            // Description
            Text(description)
                .font(.callout)
                .foregroundColor(ModalTheme.text.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(ModalTheme.gold)
                            .fontWeight(.bold)
                        Text(instruction)
                            .font(.subheadline)
                            .foregroundColor(ModalTheme.text.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ModalTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [ModalTheme.text.opacity(0.12), ModalTheme.text.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    UnifiedInfoModalView()
}
