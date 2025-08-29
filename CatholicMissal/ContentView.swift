import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var apiService = APIService.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var showingConnectionAlert = false
    @State private var isAPIConnected = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DailyReadingsView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Readings")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)
            
            PrayersView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Prayers")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(Color("CatholicRed"))
        .task {
            await initializeApp()
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToReadings)) { _ in
            selectedTab = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToPrayers)) { _ in
            selectedTab = 2
        }
        .alert("API Connection", isPresented: $showingConnectionAlert) {
            Button("OK") { }
        } message: {
            Text(isAPIConnected 
                 ? "Successfully connected to Catholic Missal API"
                 : "Unable to connect to API. Using offline sample data.")
        }
    }
    
    private func initializeApp() async {
        // Setup notification categories
        notificationManager.setupNotificationCategories()
        
        // Check API connection
        let connected = await apiService.healthCheck()
        await MainActor.run {
            isAPIConnected = connected
            showingConnectionAlert = true
        }
        
        // Clean up old data
        coreDataManager.deleteOldData()
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}