import Foundation

// MARK: - Liturgical Enums
enum LiturgicalSeason: String, CaseIterable, Codable {
    case advent = "Advent"
    case christmas = "Christmas"
    case ordinaryTime = "Ordinary Time"
    case lent = "Lent"
    case easterTriduum = "Easter Triduum"
    case easter = "Easter"
    
    var color: String {
        switch self {
        case .advent, .lent: return "Purple"
        case .christmas, .easter: return "White"
        case .ordinaryTime: return "Green"
        case .easterTriduum: return "Red"
        }
    }
}

enum LiturgicalRank: String, CaseIterable, Codable {
    case solemnity = "Solemnity"
    case feast = "Feast"
    case memorial = "Memorial"
    case optionalMemorial = "Optional Memorial"
    case weekday = "Weekday"
    case sunday = "Sunday"
}

enum LiturgicalColor: String, CaseIterable, Codable {
    case white = "White"
    case red = "Red"
    case green = "Green"
    case purple = "Purple"
    case rose = "Rose"
    case black = "Black"
}

// MARK: - Reading Models
struct Reading: Codable, Identifiable {
    let id = UUID()
    let reference: String
    let citation: String
    let text: String?
    let shortText: String?
    let source: String
    
    enum CodingKeys: String, CodingKey {
        case reference, citation, text
        case shortText = "short_text"
        case source
    }
}

struct Psalm: Codable, Identifiable {
    let id = UUID()
    let reference: String
    let refrain: String?
    let verses: [String]?
    let source: String
}

struct DailyReadings: Codable, Identifiable {
    let id = UUID()
    let date: String
    let firstReading: Reading?
    let responsorialPsalm: Psalm?
    let secondReading: Reading?
    let gospelAcclamation: String?
    let gospel: Reading?
    let source: String
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case firstReading = "first_reading"
        case responsorialPsalm = "responsorial_psalm"
        case secondReading = "second_reading"
        case gospelAcclamation = "gospel_acclamation"
        case gospel, source
        case lastUpdated = "last_updated"
    }
    
    var dateFormatted: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
}

// MARK: - Calendar Models
struct Celebration: Codable, Identifiable {
    let id = UUID()
    let name: String
    let rank: String
    let color: String
    let description: String?
    let properReadings: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, rank, color, description
        case properReadings = "proper_readings"
    }
}

struct LiturgicalDay: Codable, Identifiable {
    let id = UUID()
    let date: String
    let season: String
    let seasonWeek: Int?
    let weekday: String
    let celebrations: [Celebration]
    let primaryCelebration: Celebration?
    let color: String
    let readings: DailyReadings?
    let source: String
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case date, season, weekday, celebrations, color, readings, source
        case seasonWeek = "season_week"
        case primaryCelebration = "primary_celebration"
        case lastUpdated = "last_updated"
    }
    
    var dateFormatted: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
}

// MARK: - Prayer Models
struct Prayer: Codable, Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let text: String
    let source: String
    let language: String
    let copyrightNotice: String?
    
    enum CodingKeys: String, CodingKey {
        case name, category, text, source, language
        case copyrightNotice = "copyright_notice"
    }
}

// MARK: - API Response Models
struct ReadingsResponse: Codable {
    let readings: DailyReadings
    let success: Bool
    let sourceAttribution: String
    
    enum CodingKeys: String, CodingKey {
        case readings, success
        case sourceAttribution = "source_attribution"
    }
}

struct CalendarResponse: Codable {
    let liturgicalDay: LiturgicalDay
    let success: Bool
    let sourceAttribution: String
    
    enum CodingKeys: String, CodingKey {
        case liturgicalDay = "liturgical_day"
        case success
        case sourceAttribution = "source_attribution"
    }
}

struct PrayersResponse: Codable {
    let prayers: [Prayer]
    let success: Bool
    let sourceAttribution: String
    
    enum CodingKeys: String, CodingKey {
        case prayers, success
        case sourceAttribution = "source_attribution"
    }
}

// MARK: - Error Models
struct APIError: Error, LocalizedError {
    let message: String
    
    var errorDescription: String? {
        return message
    }
}

// MARK: - Extensions
extension Date {
    func toAPIDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func toDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }
    
    func toShortDisplayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: self)
    }
}

extension LiturgicalColor {
    var swiftUIColor: String {
        switch self {
        case .white: return "white"
        case .red: return "red"
        case .green: return "green"
        case .purple: return "purple"
        case .rose: return "pink"
        case .black: return "black"
        }
    }
}