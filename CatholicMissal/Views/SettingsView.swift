import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var dailyNotificationsEnabled = false
    @State private var prayerRemindersEnabled = false
    @State private var selectedReadingTime = Date()
    @State private var selectedMorningPrayerTime = Date()
    @State private var selectedEveningPrayerTime = Date()
    @State private var showingTimePickerSheet = false
    @State private var currentTimePicker: TimePicker = .dailyReading
    
    enum TimePicker {
        case dailyReading, morningPrayer, eveningPrayer
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Notifications Section
                Section("Notifications") {
                    Toggle("Daily Reading Reminders", isOn: $dailyNotificationsEnabled)
                        .onChange(of: dailyNotificationsEnabled) { enabled in
                            if enabled && !notificationManager.isAuthorized {
                                Task {
                                    await requestNotificationPermission()
                                }
                            } else if enabled {
                                scheduleNotifications()
                            }
                        }
                    
                    if dailyNotificationsEnabled {
                        HStack {
                            Text("Reminder Time")
                            Spacer()
                            Button(timeFormatter.string(from: selectedReadingTime)) {
                                currentTimePicker = .dailyReading
                                showingTimePickerSheet = true
                            }
                            .foregroundColor(Color("CatholicRed"))
                        }
                    }
                    
                    Toggle("Prayer Reminders", isOn: $prayerRemindersEnabled)
                        .onChange(of: prayerRemindersEnabled) { enabled in
                            NotificationSettings.setPrayerRemindersEnabled(enabled)
                            if enabled {
                                schedulePrayerReminders()
                            }
                        }
                    
                    if prayerRemindersEnabled {
                        HStack {
                            Text("Morning Prayer")
                            Spacer()
                            Button(timeFormatter.string(from: selectedMorningPrayerTime)) {
                                currentTimePicker = .morningPrayer
                                showingTimePickerSheet = true
                            }
                            .foregroundColor(Color("CatholicRed"))
                        }
                        
                        HStack {
                            Text("Evening Prayer")
                            Spacer()
                            Button(timeFormatter.string(from: selectedEveningPrayerTime)) {
                                currentTimePicker = .eveningPrayer
                                showingTimePickerSheet = true
                            }
                            .foregroundColor(Color("CatholicRed"))
                        }
                    }
                }
                
                // App Information Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("API Status")
                        Spacer()
                        HStack {
                            Circle()
                                .fill(notificationManager.isAuthorized ? .green : .red)
                                .frame(width: 8, height: 8)
                            Text(notificationManager.isAuthorized ? "Connected" : "Offline")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link("Catholic Missal API", destination: URL(string: "https://github.com/grocerysushi/catholicmissalapi")!)
                        .foregroundColor(Color("CatholicRed"))
                }
                
                // Data Sources Section
                Section("Data Sources") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This app uses liturgical data from:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• USCCB (United States Conference of Catholic Bishops)")
                            Text("• Vatican Official Sources")
                            Text("• Licensed Catholic Publishers")
                            Text("• Academic Institutions")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                // Copyright Section
                Section("Copyright Notice") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All liturgical texts are used in accordance with Church policies and fair use guidelines. This app is intended for educational and religious purposes.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("For commercial use, please ensure proper licensing from source authorities.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Actions Section
                Section("Actions") {
                    Button("Clear Cache") {
                        clearCache()
                    }
                    .foregroundColor(Color("CatholicRed"))
                    
                    Button("Reset Notifications") {
                        resetNotifications()
                    }
                    .foregroundColor(Color("CatholicRed"))
                }
                
                // Footer
                Section {
                    VStack(spacing: 8) {
                        Text("Ad Majorem Dei Gloriam")
                            .font(.caption)
                            .italic()
                            .foregroundColor(Color("CatholicRed"))
                        
                        Text("For the Greater Glory of God")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingTimePickerSheet) {
            timePickerSheet
        }
        .onAppear {
            loadSettings()
        }
    }
    
    // MARK: - Time Picker Sheet
    private var timePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Time",
                    selection: currentTimeBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle(currentTimePickerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingTimePickerSheet = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveTimeSettings()
                        showingTimePickerSheet = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var currentTimeBinding: Binding<Date> {
        switch currentTimePicker {
        case .dailyReading:
            return $selectedReadingTime
        case .morningPrayer:
            return $selectedMorningPrayerTime
        case .eveningPrayer:
            return $selectedEveningPrayerTime
        }
    }
    
    private var currentTimePickerTitle: String {
        switch currentTimePicker {
        case .dailyReading:
            return "Daily Reading Time"
        case .morningPrayer:
            return "Morning Prayer Time"
        case .eveningPrayer:
            return "Evening Prayer Time"
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    // MARK: - Helper Methods
    private func loadSettings() {
        dailyNotificationsEnabled = UserDefaults.standard.bool(forKey: "dailyNotificationsEnabled")
        prayerRemindersEnabled = NotificationSettings.getPrayerRemindersEnabled()
        
        // Load times from UserDefaults
        if let readingTimeData = UserDefaults.standard.data(forKey: "selectedReadingTime"),
           let readingTime = try? JSONDecoder().decode(Date.self, from: readingTimeData) {
            selectedReadingTime = readingTime
        } else {
            // Default to 6:00 AM
            selectedReadingTime = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date()
        }
        
        // Similar for prayer times
        if let morningTimeData = UserDefaults.standard.data(forKey: "selectedMorningPrayerTime"),
           let morningTime = try? JSONDecoder().decode(Date.self, from: morningTimeData) {
            selectedMorningPrayerTime = morningTime
        } else {
            selectedMorningPrayerTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
        }
        
        if let eveningTimeData = UserDefaults.standard.data(forKey: "selectedEveningPrayerTime"),
           let eveningTime = try? JSONDecoder().decode(Date.self, from: eveningTimeData) {
            selectedEveningPrayerTime = eveningTime
        } else {
            selectedEveningPrayerTime = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
        }
    }
    
    private func saveTimeSettings() {
        // Save times to UserDefaults
        if let readingTimeData = try? JSONEncoder().encode(selectedReadingTime) {
            UserDefaults.standard.set(readingTimeData, forKey: "selectedReadingTime")
        }
        
        if let morningTimeData = try? JSONEncoder().encode(selectedMorningPrayerTime) {
            UserDefaults.standard.set(morningTimeData, forKey: "selectedMorningPrayerTime")
        }
        
        if let eveningTimeData = try? JSONEncoder().encode(selectedEveningPrayerTime) {
            UserDefaults.standard.set(eveningTimeData, forKey: "selectedEveningPrayerTime")
        }
        
        // Reschedule notifications with new times
        if dailyNotificationsEnabled {
            scheduleNotifications()
        }
        if prayerRemindersEnabled {
            schedulePrayerReminders()
        }
    }
    
    private func requestNotificationPermission() async {
        let granted = await notificationManager.requestAuthorization()
        if granted {
            await MainActor.run {
                scheduleNotifications()
            }
        } else {
            await MainActor.run {
                dailyNotificationsEnabled = false
            }
        }
    }
    
    private func scheduleNotifications() {
        notificationManager.scheduleDailyReadingNotification()
        notificationManager.scheduleFeasterDayNotifications()
        UserDefaults.standard.set(true, forKey: "dailyNotificationsEnabled")
    }
    
    private func schedulePrayerReminders() {
        let calendar = Calendar.current
        
        var morningComponents = DateComponents()
        morningComponents.hour = calendar.component(.hour, from: selectedMorningPrayerTime)
        morningComponents.minute = calendar.component(.minute, from: selectedMorningPrayerTime)
        
        var eveningComponents = DateComponents()
        eveningComponents.hour = calendar.component(.hour, from: selectedEveningPrayerTime)
        eveningComponents.minute = calendar.component(.minute, from: selectedEveningPrayerTime)
        
        notificationManager.schedulePrayerReminders(times: [morningComponents, eveningComponents])
    }
    
    private func clearCache() {
        CoreDataManager.shared.deleteOldData()
        // Clear UserDefaults cache if any
        UserDefaults.standard.removeObject(forKey: "cachedReadings")
    }
    
    private func resetNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        notificationManager.clearBadge()
        
        if dailyNotificationsEnabled {
            scheduleNotifications()
        }
        if prayerRemindersEnabled {
            schedulePrayerReminders()
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}