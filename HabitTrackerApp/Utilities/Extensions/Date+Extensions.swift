//
//  Date+Extensions.swift
//  HabitTrackerApp
//
//  Created by Admin on 6/27/25.
//

import SwiftUI

extension Date {
    var weekDay: String {
        let calendar = Calendar.current
        let index = calendar.component(.weekday, from: self) - 1
        return calendar.weekdaySymbols[index]
    }
    
    var startOfDay: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self)
    }
    
    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    static var startDateOfThisMonth: Date {
        let calendar = Calendar.current
        guard let date = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) else {
            fatalError("No Start Date Found!")
        }
        return date
    }
    
    static var dateInThisMonth: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: .now) else {
            fatalError("No Dates in this month")
        }
        return range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: startDateOfThisMonth)
        }
    }
    
    static var startOffsetOfThisMonth: Int {
        Calendar.current.component(.weekday, from: startDateOfThisMonth) - 1
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
