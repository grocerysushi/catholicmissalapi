import SwiftUI

struct TestReadingView: View {
    @StateObject private var apiService = APIService.shared
    @State private var readings: DailyReadings?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Test date: August 29, 2025 - Memorial of the Passion of Saint John the Baptist
    private let testDate: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "2025-08-29") ?? Date()
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Test Header
                    testHeaderView
                    
                    if isLoading {
                        loadingView
                    } else if let errorMessage = errorMessage {
                        errorView(errorMessage)
                    } else if let readings = readings {
                        readingsContentView(readings)
                    }
                    
                    // Test Controls
                    testControlsView
                }
                .padding()
            }
            .navigationTitle("Test Reading")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await testAPICall()
        }
    }
    
    // MARK: - Test Header View
    private var testHeaderView: some View {
        VStack(spacing: 12) {
            Text("Testing API Call")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("CatholicRed"))
            
            Text("August 29, 2025")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Memorial of the Passion of Saint John the Baptist")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Lectionary: 429/634")
                .font(.caption)
                .foregroundColor(.secondary)
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
            
            Text("Testing API connection...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("API Connection Failed")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Showing sample data instead")
                .font(.caption)
                .foregroundColor(Color("CatholicRed"))
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Readings Content View
    private func readingsContentView(_ readings: DailyReadings) -> some View {
        LazyVStack(spacing: 20) {
            // Success Indicator
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Reading Successfully Loaded!")
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // First Reading
            if let firstReading = readings.firstReading {
                TestReadingCardView(
                    title: "First Reading",
                    reading: firstReading,
                    accentColor: Color("CatholicRed")
                )
            }
            
            // Responsorial Psalm
            if let psalm = readings.responsorialPsalm {
                TestPsalmCardView(psalm: psalm)
            }
            
            // Gospel Acclamation
            if let acclamation = readings.gospelAcclamation {
                TestAcclamationCardView(acclamation: acclamation)
            }
            
            // Gospel
            if let gospel = readings.gospel {
                TestReadingCardView(
                    title: "Gospel",
                    reading: gospel,
                    accentColor: Color("CatholicGold"),
                    isGospel: true
                )
            }
            
            // Verification Info
            verificationView(readings)
        }
    }
    
    // MARK: - Test Controls View
    private var testControlsView: some View {
        VStack(spacing: 12) {
            Text("Test Controls")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(spacing: 12) {
                Button("Test API Call") {
                    Task {
                        await testAPICall()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("CatholicRed"))
                
                Button("Use Sample Data") {
                    loadSampleData()
                }
                .buttonStyle(.bordered)
                .tint(Color("CatholicRed"))
            }
            
            // API Status
            HStack {
                Circle()
                    .fill(readings != nil ? .green : .red)
                    .frame(width: 8, height: 8)
                
                Text(readings != nil ? "Data Loaded Successfully" : "Using Fallback Data")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Verification View
    private func verificationView(_ readings: DailyReadings) -> some View {
        let testResult = TestingUtilities.verifyAugust29Reading(readings)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Verification Results")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("CatholicRed"))
                
                Spacer()
                
                Text(testResult.summary)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(testResult.isSuccess ? .green : .red)
            }
            
            // Successes
            if !testResult.successes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Successes:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    ForEach(testResult.successes, id: \.self) { success in
                        Text(success)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // Issues
            if !testResult.issues.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Issues:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    ForEach(testResult.issues, id: \.self) { issue in
                        Text(issue)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(testResult.isSuccess ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke((testResult.isSuccess ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
        )
    }
    
    private func verificationRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text("\(label):")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    private func testAPICall() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getReadingsForDate(testDate)
            await MainActor.run {
                self.readings = response.readings
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                // Load the specific sample data for August 29, 2025
                self.readings = apiService.getSampleReadings(for: testDate)
            }
        }
    }
    
    private func loadSampleData() {
        readings = apiService.getSampleReadings(for: testDate)
        errorMessage = nil
        isLoading = false
    }
}

// MARK: - Test Reading Card View
struct TestReadingCardView: View {
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
                
                // Verification checkmark
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
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
            
            HStack {
                Text("Source: \(reading.source)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if reading.source.contains("429/634") {
                    Text("✅ Correct Lectionary")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
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

// MARK: - Test Psalm Card View
struct TestPsalmCardView: View {
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
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
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

// MARK: - Test Acclamation Card View
struct TestAcclamationCardView: View {
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
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
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

// MARK: - Preview
struct TestReadingView_Previews: PreviewProvider {
    static var previews: some View {
        TestReadingView()
    }
}