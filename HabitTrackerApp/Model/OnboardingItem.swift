//
//  OnboardingItem.swift
//  HabitTrackerApp
//
//  Created by Admin on 6/26/25.
//

import SwiftUI

struct OnboardingItem: Identifiable {
    var id: String = UUID().uuidString
    var image: String
    var title: String
    var description: String
    var scale: CGFloat = 1
    var anchor: UnitPoint = .center
    var offset: CGFloat = 0
    var rotation: CGFloat = 0
    var zindex: CGFloat = 0
    var extraOffset: CGFloat = -350
}

var onboardingItems: [OnboardingItem] = [
    .init(
        image: "calendar.circle.fill",
        title: "Track your daily\nhabits",
        description: "Log your habits daily to stay\non track with your personal growth",
        scale: 1
    ),
    .init(
        image: "checkmark.circle.fill",
        title: "Stay consistent and\nbuild routines",
        description: "Form habits that stick by ticking\noff tasks and staying consistent each day",
        scale: 0.6,
        anchor: .topLeading,
        offset: -70,
        rotation: 30
    ),
    .init(
        image: "star.circle.fill",
        title: "Celebrate your\nsmall wins",
        description: "Celebrate milestones to stay\nmotivated and track your progress",
        scale: 0.5,
        anchor: .bottomLeading,
        offset: -60,
        rotation: -35
    ),
    .init(
        image: "figure.walk",
        title: "Stay motivated\nevery day",
        description: "Track streaks and use visual progress\nto stay inspired and motivated",
        scale: 0.4,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 160,
        extraOffset: -120
    ),
    .init(
        image: "clock.circle.fill",
        title: "Track your time\nand progress",
        description: "Measure your progress over time and\nadjust habits for better results",
        scale: 0.35,
        anchor: .bottomLeading,
        offset: -50,
        rotation: 250,
        extraOffset: -100
    )
]

