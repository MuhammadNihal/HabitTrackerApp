//
//  HabitTrackerAppApp.swift
//  HabitTrackerApp
//
//  Created by Admin on 6/26/25.
//

import SwiftUI

@main
struct HabitTrackerAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Habit.self)
        }
    }
}
