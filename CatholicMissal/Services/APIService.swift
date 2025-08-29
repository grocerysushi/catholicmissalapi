import Foundation
import Combine

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8000/api/v1"
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Generic API Request Method
    private func makeRequest<T: Codable>(
        endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError(message: "Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError(message: "Invalid response")
            }
            
            guard httpResponse.statusCode == 200 else {
                throw APIError(message: "Server error: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(responseType, from: data)
            return result
            
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError(message: "Failed to parse response")
        } catch let error as URLError {
            print("Network error: \(error)")
            if error.code == .notConnectedToInternet {
                throw APIError(message: "No internet connection")
            } else if error.code == .timedOut {
                throw APIError(message: "Request timed out")
            } else {
                throw APIError(message: "Network error")
            }
        } catch {
            print("Unknown error: \(error)")
            throw APIError(message: "An unexpected error occurred")
        }
    }
    
    // MARK: - Calendar Methods
    func getTodayCalendar() async throws -> CalendarResponse {
        return try await makeRequest(endpoint: "/calendar/today", responseType: CalendarResponse.self)
    }
    
    func getCalendarForDate(_ date: Date) async throws -> CalendarResponse {
        let dateString = date.toAPIDateString()
        return try await makeRequest(endpoint: "/calendar/\(dateString)", responseType: CalendarResponse.self)
    }
    
    // MARK: - Readings Methods
    func getTodayReadings() async throws -> ReadingsResponse {
        return try await makeRequest(endpoint: "/readings/today", responseType: ReadingsResponse.self)
    }
    
    func getReadingsForDate(_ date: Date) async throws -> ReadingsResponse {
        let dateString = date.toAPIDateString()
        return try await makeRequest(endpoint: "/readings/\(dateString)", responseType: ReadingsResponse.self)
    }
    
    // MARK: - Prayers Methods
    func getCommonPrayers() async throws -> PrayersResponse {
        return try await makeRequest(endpoint: "/prayers/common", responseType: PrayersResponse.self)
    }
    
    func getPrayersByCategory(_ category: String) async throws -> PrayersResponse {
        return try await makeRequest(endpoint: "/prayers/category/\(category)", responseType: PrayersResponse.self)
    }
    
    func getSeasonalPrayers(_ season: String) async throws -> PrayersResponse {
        return try await makeRequest(endpoint: "/prayers/seasonal/\(season)", responseType: PrayersResponse.self)
    }
    
    // MARK: - Health Check
    func healthCheck() async -> Bool {
        do {
            guard let url = URL(string: "\(baseURL.replacingOccurrences(of: "/api/v1", with: ""))/api/v1/info") else {
                return false
            }
            
            let (_, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            return httpResponse.statusCode == 200
        } catch {
            return false
        }
    }
}

// MARK: - Sample Data for Development/Offline Use
extension APIService {
    func getSampleReadings() -> DailyReadings {
        return DailyReadings(
            date: Date().toAPIDateString(),
            firstReading: Reading(
                reference: "Isaiah 61:1-2a, 10-11",
                citation: "Is 61:1-2a, 10-11",
                text: "The spirit of the Lord GOD is upon me, because the LORD has anointed me; he has sent me to bring glad tidings to the poor, to heal the brokenhearted, to proclaim liberty to the captives and release to the prisoners, to announce a year of favor from the LORD and a day of vindication by our God.\n\nI rejoice heartily in the LORD, in my God is the joy of my soul; for he has clothed me with a robe of salvation and wrapped me in a mantle of justice, like a bridegroom adorned with a diadem, like a bride bedecked with her jewels.\n\nAs the earth brings forth its plants, and a garden makes its growth spring up, so will the Lord GOD make justice and praise spring up before all the nations.",
                shortText: nil,
                source: "USCCB"
            ),
            responsorialPsalm: Psalm(
                reference: "Luke 1:46-48, 49-50, 53-54",
                refrain: "My soul rejoices in my God.",
                verses: [
                    "My soul proclaims the greatness of the Lord; my spirit rejoices in God my Savior, for he has looked upon his lowly servant.",
                    "The Almighty has done great things for me, and holy is his Name. He has mercy on those who fear him in every generation.",
                    "He has filled the hungry with good things, and the rich he has sent away empty. He has come to the help of his servant Israel for he has remembered his promise of mercy."
                ],
                source: "USCCB"
            ),
            secondReading: nil,
            gospelAcclamation: "Alleluia, alleluia. The Spirit of the Lord is upon me, because he has anointed me to bring glad tidings to the poor. Alleluia, alleluia.",
            gospel: Reading(
                reference: "Luke 4:16-21",
                citation: "Lk 4:16-21",
                text: "Jesus came to Nazareth, where he had grown up, and went according to his custom into the synagogue on the sabbath day. He stood up to read and was handed a scroll of the prophet Isaiah. He unrolled the scroll and found the passage where it was written:\n\nThe Spirit of the Lord is upon me, because he has anointed me to bring glad tidings to the poor. He has sent me to proclaim liberty to captives and recovery of sight to the blind, to let the oppressed go free, and to proclaim a year acceptable to the Lord.\n\nRolling up the scroll, he handed it back to the attendant and sat down, and the eyes of all in the synagogue looked intently at him. He said to them, \"Today this Scripture passage is fulfilled in your hearing.\"",
                shortText: nil,
                source: "USCCB"
            ),
            source: "USCCB",
            lastUpdated: ISO8601DateFormatter().string(from: Date())
        )
    }
    
    func getSamplePrayers() -> [Prayer] {
        return [
            Prayer(
                name: "Our Father",
                category: "common",
                text: "Our Father, who art in heaven,\nhallowed be thy name.\nThy kingdom come,\nthy will be done,\non earth as it is in heaven.\n\nGive us this day our daily bread,\nand forgive us our trespasses,\nas we forgive those who trespass against us.\n\nAnd lead us not into temptation,\nbut deliver us from evil.\n\nAmen.",
                source: "Traditional Catholic Prayer",
                language: "en",
                copyrightNotice: nil
            ),
            Prayer(
                name: "Hail Mary",
                category: "marian",
                text: "Hail Mary, full of grace,\nthe Lord is with thee.\nBlessed art thou amongst women,\nand blessed is the fruit of thy womb, Jesus.\n\nHoly Mary, Mother of God,\npray for us sinners,\nnow and at the hour of our death.\n\nAmen.",
                source: "Traditional Catholic Prayer",
                language: "en",
                copyrightNotice: nil
            ),
            Prayer(
                name: "Glory Be",
                category: "common",
                text: "Glory be to the Father,\nand to the Son,\nand to the Holy Spirit.\n\nAs it was in the beginning,\nis now, and ever shall be,\nworld without end.\n\nAmen.",
                source: "Traditional Catholic Prayer",
                language: "en",
                copyrightNotice: nil
            ),
            Prayer(
                name: "Act of Contrition",
                category: "penitential",
                text: "O my God, I am heartily sorry for having offended Thee,\nand I detest all my sins because of thy just punishments,\nbut most of all because they offend Thee, my God,\nwho art all good and deserving of all my love.\n\nI firmly resolve with the help of Thy grace\nto sin no more and to avoid the near occasion of sin.\n\nAmen.",
                source: "Traditional Catholic Prayer",
                language: "en",
                copyrightNotice: nil
            ),
            Prayer(
                name: "Apostles' Creed",
                category: "common",
                text: "I believe in God,\nthe Father almighty,\nCreator of heaven and earth,\nand in Jesus Christ, his only Son, our Lord,\nwho was conceived by the Holy Spirit,\nborn of the Virgin Mary,\nsuffered under Pontius Pilate,\nwas crucified, died and was buried;\nhe descended into hell;\non the third day he rose again from the dead;\nhe ascended into heaven,\nand is seated at the right hand of God the Father almighty;\nfrom there he will come to judge the living and the dead.\n\nI believe in the Holy Spirit,\nthe holy catholic Church,\nthe communion of saints,\nthe forgiveness of sins,\nthe resurrection of the body,\nand life everlasting.\n\nAmen.",
                source: "Traditional Catholic Prayer",
                language: "en",
                copyrightNotice: nil
            )
        ]
    }
}