//
//  Results.swift
//  Trailblazers Trivia
//
//  Created by Tony Stark on 9/19/25.
//

import SwiftUI

struct Results: View {
    @Binding var path: [Routes]

    var body: some View {
            VStack(spacing: 20) {
                Text("Quiz Results")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Your results content here
                Text("Great job on completing the trivia!")
                    .font(.title2)
                
                // Navigation buttons
                VStack(spacing: 16) {
                    Button(action: {
                        path.removeLast(path.count)
                    }) {
                        Text("Play Again")
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
    }
}
