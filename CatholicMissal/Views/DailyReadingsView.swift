import SwiftUI

struct DailyReadingsView: View {
    @StateObject private var apiService = APIService.shared
    @State private var readings: DailyReadings?
    @State private var selectedDate = Date()
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Header
                    dateHeaderView
                    
                    if isLoading {
                        loadingView
                    } else if let errorMessage = errorMessage {
                        errorView(errorMessage)
                    } else if let readings = readings {
                        readingsContentView(readings)
                    } else {
                        noReadingsView
                    }
                }
                .padding()
            }
            .navigationTitle("Daily Readings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        selectedDate = Date()
                    }
                    .foregroundColor(Color("CatholicRed"))
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerSheet
            }
        }
        .task {
            await loadReadings()
        }
        .onChange(of: selectedDate) { _ in
            Task {
                await loadReadings()
            }
        }
    }
    
    // MARK: - Date Header View
    private var dateHeaderView: some View {
        VStack(spacing: 12) {
            Button(action: { showingDatePicker = true }) {
                VStack {
                    Text(selectedDate.toDisplayString())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if Calendar.current.isDateInToday(selectedDate) {
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color("CatholicRed"))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            
            HStack(spacing: 20) {
                Button(action: { changeDate(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Color("CatholicRed"))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Button("Tomorrow") {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                    }
                    .font(.caption)
                    .foregroundColor(Color("CatholicRed"))
                    
                    Button("Next Sunday") {
                        if let nextSunday = nextSunday() {
                            selectedDate = nextSunday
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color("CatholicRed"))
                }
                
                Spacer()
                
                Button(action: { changeDate(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(Color("CatholicRed"))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color("CatholicRed"))
            
            Text("Loading readings...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error Loading Readings")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await loadReadings()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("CatholicRed"))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    // MARK: - No Readings View
    private var noReadingsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Readings Available")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Readings for \(selectedDate.toShortDisplayString()) are not available at this time.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    // MARK: - Readings Content View
    private func readingsContentView(_ readings: DailyReadings) -> some View {
        LazyVStack(spacing: 20) {
            // First Reading
            if let firstReading = readings.firstReading {
                ReadingCardView(
                    title: "First Reading",
                    reading: firstReading,
                    accentColor: Color("CatholicRed")
                )
            }
            
            // Responsorial Psalm
            if let psalm = readings.responsorialPsalm {
                PsalmCardView(psalm: psalm)
            }
            
            // Second Reading (Sundays and Solemnities)
            if let secondReading = readings.secondReading {
                ReadingCardView(
                    title: "Second Reading",
                    reading: secondReading,
                    accentColor: Color("CatholicRed")
                )
            }
            
            // Gospel Acclamation
            if let acclamation = readings.gospelAcclamation {
                AcclamationCardView(acclamation: acclamation)
            }
            
            // Gospel
            if let gospel = readings.gospel {
                ReadingCardView(
                    title: "Gospel",
                    reading: gospel,
                    accentColor: Color("CatholicGold"),
                    isGospel: true
                )
            }
            
            // Source Attribution
            sourceAttributionView(readings.source)
        }
    }
    
    // MARK: - Date Picker Sheet
    private var datePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingDatePicker = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Source Attribution View
    private func sourceAttributionView(_ source: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book")
                    .foregroundColor(.secondary)
                Text("Source Information")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text(source)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Readings used in accordance with Church policies and fair use guidelines.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Helper Methods
    private func loadReadings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getReadingsForDate(selectedDate)
            await MainActor.run {
                self.readings = response.readings
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                // Fallback to sample data for demo
                self.readings = apiService.getSampleReadings()
            }
        }
    }
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextSunday() -> Date? {
        let calendar = Calendar.current
        let today = Date()
        let daysUntilSunday = (8 - calendar.component(.weekday, from: today)) % 7
        let adjustedDays = daysUntilSunday == 0 ? 7 : daysUntilSunday
        return calendar.date(byAdding: .day, value: adjustedDays, to: today)
    }
}

// MARK: - Reading Card View
struct ReadingCardView: View {
    let title: String
    let reading: Reading
    let accentColor: Color
    let isGospel: Bool
    
    init(title: String, reading: Reading, accentColor: Color, isGospel: Bool = false) {
        self.title = title
        self.reading = reading
        self.accentColor = accentColor
        self.isGospel = isGospel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(accentColor)
                
                Spacer()
                
                if isGospel {
                    Image(systemName: "cross.fill")
                        .foregroundColor(accentColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(reading.reference)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(reading.citation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let text = reading.text {
                Text(text)
                    .font(.body)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text("Source: \(reading.source)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(0.3), lineWidth: isGospel ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Psalm Card View
struct PsalmCardView: View {
    let psalm: Psalm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Responsorial Psalm")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("CatholicRed"))
                
                Spacer()
                
                Image(systemName: "music.note")
                    .foregroundColor(Color("CatholicRed"))
            }
            
            Text(psalm.reference)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if let refrain = psalm.refrain {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Refrain:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(refrain)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color("CatholicGold").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            if let verses = psalm.verses {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(verses.enumerated()), id: \.offset) { index, verse in
                        Text(verse)
                            .font(.body)
                            .lineSpacing(2)
                    }
                }
            }
            
            Text("Source: \(psalm.source)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("CatholicRed").opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Acclamation Card View
struct AcclamationCardView: View {
    let acclamation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Gospel Acclamation")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("CatholicGold"))
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(Color("CatholicGold"))
            }
            
            Text(acclamation)
                .font(.subheadline)
                .fontWeight(.medium)
                .italic()
        }
        .padding()
        .background(Color("CatholicGold").opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("CatholicGold").opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Helper Methods Extension
extension DailyReadingsView {
    private func loadReadings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getReadingsForDate(selectedDate)
            await MainActor.run {
                self.readings = response.readings
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                // Fallback to sample data
                self.readings = apiService.getSampleReadings()
            }
        }
    }
}

// MARK: - Preview
struct DailyReadingsView_Previews: PreviewProvider {
    static var previews: some View {
        DailyReadingsView()
    }
}