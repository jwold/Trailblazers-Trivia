//
//  AboutScreen.swift
//  Trailblazers Trivia
//
//  Created by Joshua Wold and Nathan Isaac on 10/16/25.
//

import SwiftUI

struct AboutScreen: View {
    @Binding var path: [Routes]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("About")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                path.removeLast()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(Color.cardBackground)
                                    )
                                    .overlay(
                                        Circle().stroke(Color.white.opacity(0.06), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)
                    
                    // Main content card
                    VStack(alignment: .leading, spacing: 24) {
                        // App info section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Test your knowledge with challenging trivia questions across various categories. Perfect for Bible study groups, classrooms, or friendly competition.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(nil)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        // Creators section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Created by Joshua Wold and Nathan Isaac.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        // Contact section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Got questions? Please reach out with any feedback to trailblazerstrivia@gmail.com.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        // App info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("App Version")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                               let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                                Text("Version \(version) (Build \(build))")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.6))
                            } else {
                                Text("Version 1.0")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.12), .white.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 12)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct CreatorCard: View {
    let name: String
    let website: String
    let websiteDisplay: String
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Button(action: {
                    if let url = URL(string: website) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.caption)
                        Text(websiteDisplay)
                            .font(.subheadline)
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBackground.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    AboutScreen(path: .constant([]))
}
