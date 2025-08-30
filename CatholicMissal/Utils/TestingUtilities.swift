import Foundation

struct TestingUtilities {
    
    // MARK: - Reading Verification
    static func verifyAugust29Reading(_ readings: DailyReadings) -> TestResult {
        var issues: [String] = []
        var successes: [String] = []
        
        // Verify date
        if readings.date == "2025-08-29" {
            successes.append("✅ Date is correct: \(readings.date)")
        } else {
            issues.append("❌ Date mismatch: Expected 2025-08-29, got \(readings.date)")
        }
        
        // Verify memorial information
        if readings.source.contains("Memorial of the Passion of Saint John the Baptist") {
            successes.append("✅ Memorial correctly identified")
        } else {
            issues.append("❌ Memorial not identified in source")
        }
        
        // Verify lectionary number
        if readings.source.contains("429/634") || 
           readings.firstReading?.source.contains("429/634") == true {
            successes.append("✅ Lectionary 429/634 found")
        } else {
            issues.append("❌ Lectionary 429/634 not found")
        }
        
        // Verify First Reading
        if let firstReading = readings.firstReading {
            if firstReading.reference.contains("1 Thessalonians 4:1-8") {
                successes.append("✅ First Reading reference correct")
            } else {
                issues.append("❌ First Reading reference incorrect: \(firstReading.reference)")
            }
            
            if firstReading.text?.contains("Brothers and sisters") == true {
                successes.append("✅ First Reading text starts correctly")
            } else {
                issues.append("❌ First Reading text doesn't start with expected text")
            }
            
            if firstReading.text?.contains("who also gives his Holy Spirit to you") == true {
                successes.append("✅ First Reading text ends correctly")
            } else {
                issues.append("❌ First Reading text doesn't end with expected text")
            }
        } else {
            issues.append("❌ First Reading is missing")
        }
        
        // Verify Responsorial Psalm
        if let psalm = readings.responsorialPsalm {
            if psalm.reference.contains("Psalm 97") {
                successes.append("✅ Psalm reference correct")
            } else {
                issues.append("❌ Psalm reference incorrect: \(psalm.reference)")
            }
            
            if psalm.refrain?.contains("Rejoice in the Lord, you just!") == true {
                successes.append("✅ Psalm refrain correct")
            } else {
                issues.append("❌ Psalm refrain incorrect: \(psalm.refrain ?? "nil")")
            }
        } else {
            issues.append("❌ Responsorial Psalm is missing")
        }
        
        // Verify Gospel Acclamation
        if let acclamation = readings.gospelAcclamation {
            if acclamation.contains("Blessed are those who are persecuted") {
                successes.append("✅ Gospel Acclamation correct")
            } else {
                issues.append("❌ Gospel Acclamation incorrect")
            }
        } else {
            issues.append("❌ Gospel Acclamation is missing")
        }
        
        // Verify Gospel
        if let gospel = readings.gospel {
            if gospel.reference.contains("Mark 6:17-29") {
                successes.append("✅ Gospel reference correct")
            } else {
                issues.append("❌ Gospel reference incorrect: \(gospel.reference)")
            }
            
            if gospel.text?.contains("Herod was the one who had John the Baptist arrested") == true {
                successes.append("✅ Gospel text starts correctly")
            } else {
                issues.append("❌ Gospel text doesn't start correctly")
            }
            
            if gospel.text?.contains("they came and took his body and laid it in a tomb") == true {
                successes.append("✅ Gospel text ends correctly")
            } else {
                issues.append("❌ Gospel text doesn't end correctly")
            }
        } else {
            issues.append("❌ Gospel is missing")
        }
        
        return TestResult(
            isSuccess: issues.isEmpty,
            successCount: successes.count,
            issueCount: issues.count,
            successes: successes,
            issues: issues
        )
    }
    
    // MARK: - API Connection Test
    static func testAPIConnection() async -> APIConnectionResult {
        let apiService = APIService.shared
        
        // Test basic health check
        let isHealthy = await apiService.healthCheck()
        
        // Test specific endpoint
        var canFetchReadings = false
        var readingsError: String?
        
        do {
            let testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 29)) ?? Date()
            _ = try await apiService.getReadingsForDate(testDate)
            canFetchReadings = true
        } catch {
            readingsError = error.localizedDescription
        }
        
        return APIConnectionResult(
            isHealthy: isHealthy,
            canFetchReadings: canFetchReadings,
            readingsError: readingsError
        )
    }
}

// MARK: - Test Result Models
struct TestResult {
    let isSuccess: Bool
    let successCount: Int
    let issueCount: Int
    let successes: [String]
    let issues: [String]
    
    var summary: String {
        return "Test \(isSuccess ? "PASSED" : "FAILED"): \(successCount) successes, \(issueCount) issues"
    }
}

struct APIConnectionResult {
    let isHealthy: Bool
    let canFetchReadings: Bool
    let readingsError: String?
    
    var status: String {
        if isHealthy && canFetchReadings {
            return "✅ API fully functional"
        } else if isHealthy {
            return "⚠️ API responding but readings endpoint has issues"
        } else {
            return "❌ API not responding"
        }
    }
    
    var details: String {
        var details = ["Health check: \(isHealthy ? "✅" : "❌")"]
        details.append("Readings endpoint: \(canFetchReadings ? "✅" : "❌")")
        
        if let error = readingsError {
            details.append("Error: \(error)")
        }
        
        return details.joined(separator: "\n")
    }
}