//
//  HabitCalendarView.swift
//  HabitTrackerApp
//
//  Created by Admin on 6/27/25.
//

import SwiftUI

struct HabitCalendarView: View {
    var isDemo: Bool = false
    var createdAt: Date
    var frequencies: [HabitFrequency]
    var completedDates: [TimeInterval]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 12) {
            if !isDemo {
                ForEach(HabitFrequency.allCases, id: \.rawValue) { frequency in
                    Text(frequency.rawValue.prefix(3))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            ForEach(0..<Date.startOffsetOfThisMonth, id: \.self) { _ in
                Circle()
                    .fill(.clear)
                    .frame(height: 30)
                    .hSpacing(.center)
            }
            
            ForEach(Date.dateInThisMonth, id: \.self) { date in
                let day = date.format("dd")
                
                Text(day)
                    .font(.caption)
                    .frame(height: 30)
                    .hSpacing(.center)
                    .background {
                        
                        let isHabitCompleted = completedDates.contains {
                            $0 == date.timeIntervalSince1970
                        }
                        
                        let isHabitDay = frequencies.contains {
                            $0.rawValue == date.weekDay
                        } && date.startOfDay >= createdAt.startOfDay
                        
                        let isFutureHabits = isHabitDay && date.startOfDay > Date()
                        
                        if isHabitCompleted && isHabitDay && !isDemo {
                            Circle()
                                .fill(.blue.tertiary)
                        } else if isHabitDay && !isFutureHabits && !isDemo {
                            Circle()
                                .fill((date.isToday ? Color.blue : Color.red).tertiary)
                        } else {
                            if isHabitDay {
                                Circle()
                                    .fill(.fill)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    HabitCalendarView(createdAt: .now, frequencies: [.sunday, .wednesday, .saturday], completedDates: [])
}
