import SwiftUI

struct CalendarView: View {
    @StateObject private var apiService = APIService.shared
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var liturgicalDays: [String: LiturgicalDay] = [:]
    @State private var selectedLiturgicalDay: LiturgicalDay?
    @State private var showingDayDetails = false
    @State private var isLoading = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month Navigation
                monthNavigationView
                
                // Calendar Grid
                calendarGridView
                
                // Legend
                legendView
                
                Spacer()
            }
            .navigationTitle("Liturgical Calendar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDayDetails) {
                if let liturgicalDay = selectedLiturgicalDay {
                    DayDetailsView(liturgicalDay: liturgicalDay)
                }
            }
        }
        .task {
            await loadMonthData()
        }
        .onChange(of: currentMonth) { _ in
            Task {
                await loadMonthData()
            }
        }
    }
    
    // MARK: - Month Navigation View
    private var monthNavigationView: some View {
        HStack {
            Button(action: { changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(Color("CatholicRed"))
            }
            
            Spacer()
            
            VStack {
                Text(currentMonth, formatter: monthYearFormatter)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(getCurrentSeasonInfo())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(Color("CatholicRed"))
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - Calendar Grid View
    private var calendarGridView: some View {
        VStack(spacing: 0) {
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            }
            .background(Color(.systemGray6))
            
            // Calendar Days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 1) {
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        currentMonth: currentMonth,
                        liturgicalDay: liturgicalDays[dateFormatter.string(from: date)],
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        onTap: { handleDateTap(date) }
                    )
                }
            }
            .background(Color(.systemGray5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // MARK: - Legend View
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Liturgical Colors")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(LiturgicalColor.allCases, id: \.self) { color in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(color.rawValue.lowercased()))
                                .frame(width: 12, height: 12)
                            
                            Text(color.rawValue)
                                .font(.caption)
                        }
                    }
                    
                    Spacer(minLength: 16)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(Color("CatholicGold"))
                        Text("Solemnity")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(Color("CatholicRed"))
                        Text("Feast")
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Computed Properties
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end
        
        // Get the first day of the week for the month
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysFromPreviousMonth = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        guard let calendarStart = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: monthStart) else {
            return []
        }
        
        // Calculate how many days to show (6 weeks = 42 days)
        let daysToShow = 42
        
        var days: [Date] = []
        for i in 0..<daysToShow {
            if let day = calendar.date(byAdding: .day, value: i, to: calendarStart) {
                days.append(day)
            }
        }
        
        return days
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    // MARK: - Helper Methods
    private func getCurrentSeasonInfo() -> String {
        // This would typically come from the API, but for now we'll estimate
        let month = calendar.component(.month, from: currentMonth)
        switch month {
        case 12, 1: return "Christmas Season"
        case 2, 3: return "Lent / Easter Season"
        case 4, 5: return "Easter Season"
        case 11: return "Advent Season"
        default: return "Ordinary Time"
        }
    }
    
    private func changeMonth(by months: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: months, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func handleDateTap(_ date: Date) {
        selectedDate = date
        
        let dateString = dateFormatter.string(from: date)
        if let liturgicalDay = liturgicalDays[dateString] {
            selectedLiturgicalDay = liturgicalDay
            showingDayDetails = true
        } else {
            // Fetch data for this specific date
            Task {
                await loadDayDetails(for: date)
            }
        }
    }
    
    private func loadMonthData() async {
        isLoading = true
        
        // For demo purposes, we'll create some sample liturgical data
        await MainActor.run {
            // Create sample data for the current month
            let today = Date()
            let todayString = dateFormatter.string(from: today)
            
            liturgicalDays[todayString] = LiturgicalDay(
                date: todayString,
                season: "Ordinary Time",
                seasonWeek: 1,
                weekday: DateFormatter().weekdaySymbols[calendar.component(.weekday, from: today) - 1],
                celebrations: [],
                primaryCelebration: nil,
                color: "Green",
                readings: nil,
                source: "Sample Data",
                lastUpdated: ISO8601DateFormatter().string(from: Date())
            )
            
            isLoading = false
        }
    }
    
    private func loadDayDetails(for date: Date) async {
        do {
            let response = try await apiService.getCalendarForDate(date)
            await MainActor.run {
                let dateString = dateFormatter.string(from: date)
                liturgicalDays[dateString] = response.liturgicalDay
                selectedLiturgicalDay = response.liturgicalDay
                showingDayDetails = true
            }
        } catch {
            print("Error loading day details: \(error)")
        }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let currentMonth: Date
    let liturgicalDay: LiturgicalDay?
    let isSelected: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
                
                if let celebration = liturgicalDay?.primaryCelebration {
                    celebrationIndicator(for: celebration)
                }
                
                if let liturgicalDay = liturgicalDay {
                    liturgicalColorIndicator(liturgicalDay.color)
                }
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    private var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var textColor: Color {
        if isToday {
            return Color("CatholicRed")
        } else if !isCurrentMonth {
            return .secondary
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color("CatholicGold").opacity(0.3)
        } else if isToday {
            return Color("CatholicRed").opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color("CatholicGold")
        } else if isToday {
            return Color("CatholicRed")
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var borderWidth: CGFloat {
        (isSelected || isToday) ? 2 : 0.5
    }
    
    // MARK: - Helper Views
    private func celebrationIndicator(for celebration: Celebration) -> some View {
        HStack(spacing: 2) {
            if celebration.rank == "Solemnity" {
                Image(systemName: "crown.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color("CatholicGold"))
            } else if celebration.rank == "Feast" {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color("CatholicRed"))
            }
        }
    }
    
    private func liturgicalColorIndicator(_ color: String) -> some View {
        Circle()
            .fill(Color(color.lowercased()))
            .frame(width: 6, height: 6)
    }
}

// MARK: - Day Details View
struct DayDetailsView: View {
    let liturgicalDay: LiturgicalDay
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date Header
                    if let date = liturgicalDay.dateFormatted {
                        Text(date.toDisplayString())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("CatholicRed"))
                    }
                    
                    // Basic Information
                    liturgicalInfoCard
                    
                    // Celebrations
                    if !liturgicalDay.celebrations.isEmpty {
                        celebrationsCard
                    }
                    
                    // Source Information
                    sourceCard
                }
                .padding()
            }
            .navigationTitle("Liturgical Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Liturgical Info Card
    private var liturgicalInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Liturgical Information")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                infoRow("Season", liturgicalDay.season)
                infoRow("Weekday", liturgicalDay.weekday)
                infoRow("Liturgical Color", liturgicalDay.color)
                
                if let seasonWeek = liturgicalDay.seasonWeek {
                    infoRow("Week", "Week \(seasonWeek)")
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Celebrations Card
    private var celebrationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Celebrations")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(liturgicalDay.celebrations) { celebration in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(celebration.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if celebration.rank == "Solemnity" {
                            Image(systemName: "crown.fill")
                                .foregroundColor(Color("CatholicGold"))
                        } else if celebration.rank == "Feast" {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color("CatholicRed"))
                        }
                    }
                    
                    Text(celebration.rank)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let description = celebration.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Source Card
    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book")
                    .foregroundColor(.secondary)
                Text("Source Information")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text(liturgicalDay.source)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let lastUpdated = ISO8601DateFormatter().date(from: liturgicalDay.lastUpdated) {
                Text("Last updated: \(lastUpdated, formatter: updateFormatter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Views
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - Formatters
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var updateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    // MARK: - Helper Methods
    private func getCurrentSeasonInfo() -> String {
        let month = calendar.component(.month, from: currentMonth)
        switch month {
        case 12, 1: return "Christmas Season"
        case 2, 3: return "Lent / Easter Season"
        case 4, 5: return "Easter Season"
        case 11: return "Advent Season"
        default: return "Ordinary Time"
        }
    }
    
    private func changeMonth(by months: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: months, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func loadMonthData() async {
        isLoading = true
        
        // In a real implementation, you would fetch data for the entire month
        // For now, we'll just load today's data as a sample
        do {
            let response = try await apiService.getTodayCalendar()
            await MainActor.run {
                let todayString = Date().toAPIDateString()
                liturgicalDays[todayString] = response.liturgicalDay
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

// MARK: - Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}