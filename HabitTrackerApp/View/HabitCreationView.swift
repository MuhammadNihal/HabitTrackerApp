//
//  HabitCreationView.swift
//  HabitTrackerApp
//
//  Created by Admin on 6/28/25.
//

import SwiftUI
import UserNotifications

struct HabitCreationView: View {
    var habit: Habit?
    @State private var name: String = ""
    @State private var frequencies: [HabitFrequency] = []
    @State private var notificationDate: Date = Date()
    @State private var enablNotifications: Bool = false
    @State private var isNotificationPermissionGranted: Bool = false
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Workout for 15 mins", text: $name)
                    .font(.title)
                    .padding(.bottom, 10)
                
                Text("Habit Frequency")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 5)
                
                HabitCalendarView(
                    isDemo: isNewHabit,
                    createdAt: habit?.createdAt ?? .now,
                    frequencies: frequencies,
                    completedDates: habit?.completedDates ?? []
                )
                .applyPaddedBackground(15)
                
                if isNewHabit {
                    FrequencyPicker()
                        .applyPaddedBackground(10)
                }
                
                Text("Notifications")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 5)
                
                NotificationProperties()
                
                HabitCreationButton()
                    .padding(.top, 10)
            }
            .padding(15)
        }
        .animation(.snappy, value: enablNotifications)
        .background(.primary.opacity(0.05))
        .toolbarVisibility(.hidden, for: .navigationBar)
        .task {
            isNotificationPermissionGranted = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
        }
        .onAppear {
            guard let habit else { return }
            name = habit.name
            enablNotifications = habit.isNotificationEnabled
            notificationDate = habit.notificationTiming ?? .now
            frequencies = habit.frequencies
        }
    }
    
    @ViewBuilder
    func FrequencyPicker() -> some View {
        frequencyPickerView
    }
    
    @ViewBuilder
    func NotificationProperties() -> some View {
        Toggle("Enable Remainder Notification", isOn: $enablNotifications)
            .font(.callout)
            .tint(.blue)
            .applyPaddedBackground(12)
            .disableWithOpacity(!isNotificationPermissionGranted)
        
        if enablNotifications && isNotificationPermissionGranted {
            DatePicker("Preffered Remainder Time", selection: $notificationDate, displayedComponents: [.hourAndMinute])
                .applyPaddedBackground(12)
                .transition(.blurReplace)
        }
        
        if !isNotificationPermissionGranted {
            Text("Notification Permission is denied, please enable it in settings.")
                .font(.caption2)
                .foregroundStyle(.gray)
        }
    }
    
    @ViewBuilder
    func HabitCreationButton() -> some View {
        HStack(spacing: 10) {
            Button {
                createHabit()
            } label: {
                HStack(spacing: 10) {
                    Text("\(isNewHabit ? "Create" : "Update") Habit")
                    Image(systemName: "checkmark.circle.fill")
                }
                .fontWeight(.semibold)
                .hSpacing(.center)
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .background(.blue.gradient, in: .rect(cornerRadius: 10))
                .contentShape(.rect)
            }
            .disableWithOpacity(habitValidation)
            
            if !isNewHabit {
                Button {
                    guard let habit else { return }
                    dismiss()
                    Task {
                        try? await Task.sleep(for: .seconds(0.2))
                        context.delete(habit)
                        try? context.save()
                    }
                } label: {
                    Image(systemName: "trash")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(.red.gradient, in: .circle)
                }
            }
        }
    }
}

extension HabitCreationView {
    var isNewHabit: Bool {
        habit == nil
    }
    
    private func cancelNotifications(_ ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    private func scheduleNotifications() async throws -> [String] {
        var notificationsIDs: [String] = []
        let weekdaySymbols: [String] = Calendar.current.weekdaySymbols
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Remainder"
        content.body = "Complete your \(name) habit!"
        
        for frequency in self.frequencies {
            let id: String = UUID().uuidString
            let hour = Calendar.current.component(.hour, from: notificationDate)
            let minute = Calendar.current.component(.minute, from: notificationDate)
            
            if let dayIndex = weekdaySymbols.firstIndex(of: frequency.rawValue) {
                var scheduleDateComponent = DateComponents()
                scheduleDateComponent.weekday = dayIndex + 1
                scheduleDateComponent.hour = hour
                scheduleDateComponent.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: scheduleDateComponent, repeats: true)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)
                notificationsIDs.append(id)
            }
        }
        
        return notificationsIDs
    }
    
    private func createHabit() {
        Task { @MainActor in
            if let habit {
                habit.name = name
                cancelNotifications(habit.notificationIDs)
                if enablNotifications {
                    let ids = (try? await scheduleNotifications()) ?? []
                    habit.notificationTiming = notificationDate
                    habit.notificationIDs = ids
                } else {
                    habit.notificationIDs = []
                    habit.notificationTiming = nil
                }
            } else {
                if enablNotifications {
                    let notificationIDs = (try? await scheduleNotifications()) ?? []
                    let habit = Habit(name: name, frequencies: frequencies, notificationIDs: notificationIDs, notificationTiming: notificationDate)
                    context.insert(habit)
                } else {
                    let habit = Habit(name: name, frequencies: frequencies)
                    context.insert(habit)
                }
            }
            
            try? context.save()
            dismiss()
        }
    }
    
    var habitValidation: Bool {
        frequencies.isEmpty || name.isEmpty
    }
    
    var frequencyPickerView: some View {
        HStack(spacing: 5) {
            ForEach(HabitFrequency.allCases, id: \.rawValue) { frequency in
                Text(frequency.rawValue.prefix(3))
                    .font(.caption)
                    .hSpacing(.center)
                    .frame(height: 30)
                    .background {
                        if frequencies.contains(frequency) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.fill)
                        }
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            if frequencies.contains(frequency) {
                                frequencies.removeAll(where: { $0 == frequency })
                            } else {
                                frequencies.append(frequency)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    HabitCreationView()
}
