import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Daily Reading Notifications
    func scheduleDailyReadingNotification() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Mass Readings"
        content.body = "Today's readings are now available"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 6:00 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 6
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-readings",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule daily notification: \(error)")
            }
        }
    }
    
    // MARK: - Feast Day Notifications
    func scheduleFeasterDayNotifications() {
        guard isAuthorized else { return }
        
        let feastDays = [
            (12, 25, "Christmas Day", "Celebrate the birth of our Lord Jesus Christ"),
            (1, 1, "Mary, Mother of God", "Honor the Blessed Virgin Mary"),
            (8, 15, "Assumption of Mary", "Celebrate Mary's assumption into heaven"),
            (11, 1, "All Saints Day", "Honor all the saints in heaven"),
            (12, 8, "Immaculate Conception", "Celebrate Mary's immaculate conception")
        ]
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        for (month, day, title, message) in feastDays {
            var dateComponents = DateComponents()
            dateComponents.year = currentYear
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = 8
            dateComponents.minute = 0
            
            if let date = calendar.date(from: dateComponents), date > Date() {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = message
                content.sound = .default
                content.categoryIdentifier = "feast-day"
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "feast-\(month)-\(day)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Failed to schedule feast day notification: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Prayer Reminder Notifications
    func schedulePrayerReminders(times: [DateComponents]) {
        guard isAuthorized else { return }
        
        // Remove existing prayer reminders
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["prayer-reminder-morning", "prayer-reminder-evening"]
        )
        
        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Prayer Reminder"
            content.body = "Take a moment for prayer and reflection"
            content.sound = .default
            content.categoryIdentifier = "prayer-reminder"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            let identifier = index == 0 ? "prayer-reminder-morning" : "prayer-reminder-evening"
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule prayer reminder: \(error)")
                }
            }
        }
    }
    
    // MARK: - Notification Categories
    func setupNotificationCategories() {
        let readingAction = UNNotificationAction(
            identifier: "open-reading",
            title: "Read Today's Gospel",
            options: [.foreground]
        )
        
        let prayerAction = UNNotificationAction(
            identifier: "open-prayers",
            title: "Open Prayers",
            options: [.foreground]
        )
        
        let readingCategory = UNNotificationCategory(
            identifier: "daily-reading",
            actions: [readingAction],
            intentIdentifiers: [],
            options: []
        )
        
        let prayerCategory = UNNotificationCategory(
            identifier: "prayer-reminder",
            actions: [prayerAction],
            intentIdentifiers: [],
            options: []
        )
        
        let feastCategory = UNNotificationCategory(
            identifier: "feast-day",
            actions: [readingAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            readingCategory,
            prayerCategory,
            feastCategory
        ])
    }
    
    // MARK: - Badge Management
    func updateBadge(count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func clearBadge() {
        updateBadge(count: 0)
    }
    
    // MARK: - Notification Handling
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let actionIdentifier = response.actionIdentifier
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        switch actionIdentifier {
        case "open-reading":
            // Navigate to readings view
            NotificationCenter.default.post(name: .navigateToReadings, object: nil)
        case "open-prayers":
            // Navigate to prayers view
            NotificationCenter.default.post(name: .navigateToPrayers, object: nil)
        default:
            break
        }
        
        clearBadge()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToReadings = Notification.Name("navigateToReadings")
    static let navigateToPrayers = Notification.Name("navigateToPrayers")
}

// MARK: - Settings
struct NotificationSettings {
    static let dailyReadingTimeKey = "dailyReadingTime"
    static let prayerRemindersEnabledKey = "prayerRemindersEnabled"
    static let morningPrayerTimeKey = "morningPrayerTime"
    static let eveningPrayerTimeKey = "eveningPrayerTime"
    
    static func getDailyReadingTime() -> DateComponents {
        let hour = UserDefaults.standard.object(forKey: dailyReadingTimeKey) as? Int ?? 6
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        return components
    }
    
    static func setDailyReadingTime(_ hour: Int) {
        UserDefaults.standard.set(hour, forKey: dailyReadingTimeKey)
    }
    
    static func getPrayerRemindersEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: prayerRemindersEnabledKey)
    }
    
    static func setPrayerRemindersEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: prayerRemindersEnabledKey)
    }
}