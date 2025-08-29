import SwiftUI
import Foundation

// MARK: - Date Extensions
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
    
    func liturgicalYear() -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        
        // Liturgical year starts with Advent (usually late November)
        // If we're in November or December, we're in the liturgical year starting that year
        // Otherwise, we're in the liturgical year that started the previous year
        return month >= 11 ? year : year - 1
    }
}

// MARK: - Color Extensions
extension Color {
    static let catholicRed = Color("CatholicRed")
    static let catholicGold = Color("CatholicGold")
    
    init(liturgicalColor: String) {
        switch liturgicalColor.lowercased() {
        case "white":
            self = .white
        case "red":
            self = .red
        case "green":
            self = .green
        case "purple":
            self = .purple
        case "rose":
            self = .pink
        case "black":
            self = .black
        default:
            self = .gray
        }
    }
}

// MARK: - String Extensions
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    var localizedCapitalized: String {
        return self.capitalizingFirstLetter()
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func liturgicalCardStyle(color: Color = Color("CatholicRed")) -> some View {
        self
            .cardStyle()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
    
    func catholicButtonStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("CatholicRed"))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Liturgical Utilities
struct LiturgicalUtilities {
    static func getLiturgicalSeason(for date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // Simplified liturgical season calculation
        // In a real app, this would be more complex and accurate
        switch month {
        case 12:
            if day >= 25 {
                return "Christmas"
            } else if day >= 3 {
                return "Advent"
            } else {
                return "Ordinary Time"
            }
        case 1:
            if day <= 13 {
                return "Christmas"
            } else {
                return "Ordinary Time"
            }
        case 2, 3:
            return "Lent"
        case 4:
            return "Easter"
        case 5:
            return "Easter"
        case 11:
            if day >= 27 {
                return "Advent"
            } else {
                return "Ordinary Time"
            }
        default:
            return "Ordinary Time"
        }
    }
    
    static func getLiturgicalColor(for season: String, date: Date) -> String {
        switch season {
        case "Advent", "Lent":
            return "Purple"
        case "Christmas", "Easter":
            return "White"
        case "Ordinary Time":
            return "Green"
        default:
            return "Green"
        }
    }
    
    static func isHolyDay(date: Date) -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // Major holy days
        let holyDays = [
            (12, 25), // Christmas
            (1, 1),   // Mary, Mother of God
            (8, 15),  // Assumption
            (11, 1),  // All Saints
            (12, 8)   // Immaculate Conception
        ]
        
        return holyDays.contains { $0.0 == month && $0.1 == day }
    }
}

// MARK: - Haptic Feedback
extension View {
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Network Monitoring
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    
    // In a real app, you would implement proper network monitoring
    // For now, this is a placeholder
    func startMonitoring() {
        // Implementation would go here
    }
    
    func stopMonitoring() {
        // Implementation would go here
    }
}