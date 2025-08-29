import SwiftUI

struct PrayersView: View {
    @StateObject private var apiService = APIService.shared
    @State private var prayers: [Prayer] = []
    @State private var filteredPrayers: [Prayer] = []
    @State private var selectedCategory = "common"
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var expandedPrayers: Set<String> = []
    
    private let categories = [
        ("common", "Common", "book"),
        ("marian", "Marian", "star"),
        ("penitential", "Penitential", "cross"),
        ("eucharistic", "Eucharistic", "heart")
    ]
    
    private let seasons = [
        ("advent", "Advent"),
        ("christmas", "Christmas"),
        ("lent", "Lent"),
        ("easter", "Easter")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBarView
                
                // Category Tabs
                categoryTabsView
                
                // Content
                if isLoading {
                    loadingView
                } else if let errorMessage = errorMessage {
                    errorView(errorMessage)
                } else if filteredPrayers.isEmpty {
                    emptyStateView
                } else {
                    prayersListView
                }
            }
            .navigationTitle("Catholic Prayers")
            .navigationBarTitleDisplayMode(.large)
        }
        .searchable(text: $searchText, prompt: "Search prayers...")
        .task {
            await loadPrayers()
        }
        .onChange(of: selectedCategory) { _ in
            Task {
                await loadPrayers()
            }
        }
        .onChange(of: searchText) { _ in
            filterPrayers()
        }
    }
    
    // MARK: - Search Bar View
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search prayers...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Category Tabs View
    private var categoryTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.0) { category in
                    CategoryTabView(
                        category: category.0,
                        label: category.1,
                        icon: category.2,
                        isSelected: selectedCategory == category.0,
                        onTap: { selectedCategory = category.0 }
                    )
                }
                
                // Seasonal Separator
                Divider()
                    .frame(height: 20)
                
                ForEach(seasons, id: \.0) { season in
                    CategoryTabView(
                        category: season.0,
                        label: season.1,
                        icon: "leaf",
                        isSelected: selectedCategory == season.0,
                        onTap: { selectedCategory = season.0 }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color("CatholicRed"))
            
            Text("Loading prayers...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error Loading Prayers")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await loadPrayers()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("CatholicRed"))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Prayers Found")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty 
                 ? "No prayers available in the \(selectedCategory) category"
                 : "No prayers match your search \"\(searchText)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Prayers List View
    private var prayersListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredPrayers) { prayer in
                    PrayerCardView(
                        prayer: prayer,
                        isExpanded: expandedPrayers.contains(prayer.name),
                        onToggle: { togglePrayerExpansion(prayer.name) }
                    )
                }
                
                // Footer Quote
                footerQuoteView
            }
            .padding()
        }
    }
    
    // MARK: - Footer Quote View
    private var footerQuoteView: some View {
        VStack(spacing: 8) {
            Text("\"Pray without ceasing\"")
                .font(.title3)
                .fontWeight(.semibold)
                .italic()
                .foregroundColor(Color("CatholicRed"))
            
            Text("1 Thessalonians 5:17")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("These prayers are part of the rich tradition of Catholic spirituality. Use them for personal devotion and meditation.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 20)
    }
    
    // MARK: - Helper Methods
    private func loadPrayers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: PrayersResponse
            
            if categories.contains(where: { $0.0 == selectedCategory }) {
                if selectedCategory == "common" {
                    response = try await apiService.getCommonPrayers()
                } else {
                    response = try await apiService.getPrayersByCategory(selectedCategory)
                }
            } else {
                response = try await apiService.getSeasonalPrayers(selectedCategory)
            }
            
            await MainActor.run {
                self.prayers = response.prayers
                self.filteredPrayers = response.prayers
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                // Fallback to sample data
                self.prayers = apiService.getSamplePrayers().filter { $0.category == selectedCategory }
                self.filteredPrayers = self.prayers
            }
        }
    }
    
    private func filterPrayers() {
        if searchText.isEmpty {
            filteredPrayers = prayers
        } else {
            filteredPrayers = prayers.filter { prayer in
                prayer.name.localizedCaseInsensitiveContains(searchText) ||
                prayer.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func togglePrayerExpansion(_ prayerName: String) {
        if expandedPrayers.contains(prayerName) {
            expandedPrayers.remove(prayerName)
        } else {
            expandedPrayers.insert(prayerName)
        }
    }
}

// MARK: - Category Tab View
struct CategoryTabView: View {
    let category: String
    let label: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color("CatholicRed") : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Prayer Card View
struct PrayerCardView: View {
    let prayer: Prayer
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prayer.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("CatholicRed"))
                    
                    Text(prayer.category.capitalized.replacingOccurrences(of: "_", with: " "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(isExpanded ? "Collapse" : "Expand") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onToggle()
                    }
                }
                .font(.caption)
                .foregroundColor(Color("CatholicRed"))
            }
            
            // Prayer Text
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(prayer.text.components(separatedBy: "\n"), id: \.self) { line in
                        if !line.isEmpty {
                            Text(line)
                                .font(.body)
                                .lineSpacing(2)
                                .italic()
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
                // Source Information
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                    
                    Text("Source: \(prayer.source)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if let copyright = prayer.copyrightNotice {
                        Text("© \(copyright)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text(prayer.text.prefix(100) + (prayer.text.count > 100 ? "..." : ""))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("Tap to read full prayer")
                    .font(.caption)
                    .foregroundColor(Color("CatholicRed"))
                    .onTapGesture {
                        onToggle()
                    }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("CatholicRed").opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
struct PrayersView_Previews: PreviewProvider {
    static var previews: some View {
        PrayersView()
    }
}