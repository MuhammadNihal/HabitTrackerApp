//
//  ContentView.swift
//  HabitTrackerApp
//
//  Created by Admin on 6/26/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted: Bool = false
    
    var body: some View {
        ZStack {
            if isOnboardingCompleted {
                NavigationStack {
                    HomeView()
                }
                .transition(.move(edge: .trailing))
            } else {
                OnboardingView()
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.snappy(duration: 0.25, extraBounce: 0), value: isOnboardingCompleted)
    }
}

#Preview {
    ContentView()
}
