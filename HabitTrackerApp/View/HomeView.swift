//
//  HomeView.swift
//  HabitTrackerApp
//
//  Created by Admin on 6/27/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage("username") private var username: String = ""
    @Query(sort: [.init(\Habit.createdAt, order: .reverse)], animation: .snappy) private var habits: [Habit]
    @Namespace private var animationID
    @State private var selectedHabit: Habit?
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 15) {
                HeaderView()
                    .padding(.bottom, 15)
                
                ForEach(habits) { habit in
                    HabitCardView(habit: habit, animationID: animationID)
                        .onTapGesture {
                            selectedHabit = habit
                        }
                }
            }
            .padding(15)
            .overlay {
                if habits.isEmpty {
                    ContentUnavailableView("Start tracking your habits", systemImage: "checkmark.seal.fill")
                        .fixedSize(horizontal: false, vertical: true)
                        .visualEffect { content, proxy in
                            content
                                .offset(y: ((proxy.bounds(of: .scrollView)?.height ?? 0) - 50) / 2)
                        }
                }
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .background {
            Rectangle()
                .fill(.primary.opacity(0.05))
                .ignoresSafeArea()
                .scaleEffect(1.5)
        }
        .safeAreaInset(edge: .bottom) {
            CreateButton()
        }
        .navigationDestination(item: $selectedHabit) { habit in
            HabitCreationView(habit: habit)
                .navigationTransition(.zoom(sourceID: habit.uniqueID, in: animationID))
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back!")
                .font(.largeTitle.bold())
            
            HStack(spacing: 0) {
                Text(username)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(", " + Date.startDateOfThisMonth.format("MMMM YY"))
                    .textScale(.secondary)
                    .foregroundStyle(.gray)
            }
            .font(.title3)
        }
        .hSpacing(.leading)
    }
    
    @ViewBuilder
    func CreateButton() -> some View {
        NavigationLink {
            HabitCreationView()
                .navigationTransition(.zoom(sourceID: "createbutton", in: animationID))
        } label: {
            HStack(spacing: 10) {
                Text("Create Habit")
                
                Image(systemName: "plus.circle.fill")
            }
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.blue.gradient, in: .capsule)
            .matchedTransitionSource(id: "createbutton", in: animationID)
        }
        .hSpacing(.center)
        .padding(.vertical, 10)
        .background {
            Rectangle()
                .fill(.background)
                .mask {
                    Rectangle()
                        .fill(.linearGradient(colors: [
                            .white.opacity(0),
                            .white.opacity(0.5),
                            .white,
                            .white
                        ], startPoint: .top, endPoint: .bottom))
                }
                .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
