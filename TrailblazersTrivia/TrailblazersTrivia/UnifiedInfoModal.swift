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
    
    @State private var singlePlayerExpanded = false
    @State private var twoPlayerExpanded = false
    @State private var groupExpanded = false
    
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
                                // Single Player DisclosureGroup
                                DisclosureGroup(
                                    isExpanded: $singlePlayerExpanded,
                                    content: {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Test your knowledge solo with multiple choice questions.")
                                                .font(.callout)
                                                .foregroundColor(ModalTheme.text.opacity(0.7))
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("• Select answers from 4 options")
                                                Text("• Results show immediately")
                                                Text("• Reach 10 points or answer 20 questions")
                                            }
                                            .font(.subheadline)
                                            .foregroundColor(ModalTheme.text.opacity(0.8))
                                        }
                                        .padding(.top, 8)
                                    },
                                    label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "person.fill")
                                                .foregroundColor(ModalTheme.gold)
                                            Text("Single Player")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(ModalTheme.text)
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
                                    }
                                )
                                .accentColor(ModalTheme.gold)
                                .padding(.horizontal, 24)
                                
                                // 2 Player DisclosureGroup
                                DisclosureGroup(
                                    isExpanded: $twoPlayerExpanded,
                                    content: {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Two players take turns on the same device.")
                                                .font(.callout)
                                                .foregroundColor(ModalTheme.text.opacity(0.7))
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("• Current player reads and answers")
                                                Text("• Pass device after each question")
                                                Text("• First to 10 points wins")
                                            }
                                            .font(.subheadline)
                                            .foregroundColor(ModalTheme.text.opacity(0.8))
                                        }
                                        .padding(.top, 8)
                                    },
                                    label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "person.2.fill")
                                                .foregroundColor(ModalTheme.gold)
                                            Text("2 Player")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(ModalTheme.text)
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
                                    }
                                )
                                .accentColor(ModalTheme.gold)
                                .padding(.horizontal, 24)
                                
                                // Group DisclosureGroup
                                DisclosureGroup(
                                    isExpanded: $groupExpanded,
                                    content: {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Group setting with two teams competing.")
                                                .font(.callout)
                                                .foregroundColor(ModalTheme.text.opacity(0.7))
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("• Read question to both teams")
                                                Text("• First team to shout wins the turn")
                                                Text("• Award points for correct answers")
                                            }
                                            .font(.subheadline)
                                            .foregroundColor(ModalTheme.text.opacity(0.8))
                                        }
                                        .padding(.top, 8)
                                    },
                                    label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "megaphone.fill")
                                                .foregroundColor(ModalTheme.gold)
                                            Text("Group")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(ModalTheme.text)
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
                                    }
                                )
                                .accentColor(ModalTheme.gold)
                                .padding(.horizontal, 24)
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
                                // Creators
                                Text("Created by Joshua Wold and Nathan Isaac.")
                                    .font(.body)
                                    .foregroundColor(ModalTheme.text.opacity(0.8))
                                
                                // Contact
                                Text("Got questions? Please reach out with any feedback to trailblazerstrivia@gmail.com.")
                                    .font(.body)
                                    .foregroundColor(ModalTheme.text.opacity(0.8))
                                
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
