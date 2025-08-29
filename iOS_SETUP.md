# Catholic Missal iOS App - Setup Guide

## 📱 iOS App Overview

I've created a comprehensive native iOS app for the Catholic Missal that integrates with the Catholic Missal API. The app is built using SwiftUI and includes all the features you'd expect from a modern Catholic liturgical app.

## 🎯 Features

### 📖 Daily Mass Readings
- **Interactive Date Navigation**: Swipe or tap to navigate between dates
- **Today's Readings**: Quick access to current day's readings
- **Complete Liturgy**: First reading, responsorial psalm, second reading (when applicable), gospel acclamation, and gospel
- **Beautiful Typography**: Optimized for reading scripture on mobile devices
- **Offline Support**: Core Data storage for offline reading access

### 📅 Liturgical Calendar
- **Monthly Calendar View**: Interactive calendar with liturgical colors
- **Liturgical Seasons**: Visual representation of the liturgical year
- **Feast Days**: Solemnities and feasts with special indicators
- **Day Details**: Tap any date for detailed liturgical information
- **Color Coding**: Proper liturgical colors (White, Red, Green, Purple, Rose, Black)

### 🙏 Prayer Collections
- **Categorized Prayers**: Common, Marian, Penitential, Eucharistic
- **Seasonal Prayers**: Special prayers for Advent, Christmas, Lent, Easter
- **Search Functionality**: Find prayers by name or content
- **Expandable Cards**: Tap to read full prayer text
- **Favorites**: Save your favorite prayers for quick access

### ⚙️ Settings & Notifications
- **Daily Reading Reminders**: Customizable notification times
- **Prayer Reminders**: Morning and evening prayer notifications
- **Feast Day Alerts**: Notifications for major holy days
- **Offline Cache Management**: Clear cached data
- **API Connection Status**: Monitor connection to the API

## 🏗️ Technical Architecture

### SwiftUI + Combine
- **Modern SwiftUI**: Native iOS interface with smooth animations
- **Reactive Programming**: Combine framework for data flow
- **State Management**: ObservableObject pattern for clean architecture

### Core Data Integration
- **Offline Storage**: Save readings and prayers for offline access
- **Favorites System**: Store user's favorite prayers
- **Cache Management**: Automatic cleanup of old data

### Networking Layer
- **URLSession**: Native networking with proper error handling
- **Async/Await**: Modern Swift concurrency
- **Fallback Data**: Sample data when API is unavailable

## 📁 Project Structure

```
CatholicMissal/
├── CatholicMissalApp.swift           # Main app entry point
├── ContentView.swift                 # Tab navigation controller
├── Models/
│   └── LiturgicalModels.swift       # Data models matching API
├── Views/
│   ├── DailyReadingsView.swift      # Daily readings interface
│   ├── CalendarView.swift           # Liturgical calendar
│   ├── PrayersView.swift            # Prayer collections
│   └── SettingsView.swift           # App settings
├── Services/
│   ├── APIService.swift             # API communication layer
│   ├── CoreDataManager.swift        # Offline data storage
│   └── NotificationManager.swift    # Push notifications
├── Utils/
│   └── Extensions.swift             # Helper extensions
├── Assets.xcassets/                 # App icons and colors
└── CatholicMissal.xcdatamodeld/     # Core Data model
```

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+** (for iOS 16+ support)
- **iOS 16.0+** target deployment
- **macOS** for development
- **Catholic Missal API** running on accessible server

### Opening in Xcode

1. **Open the project**:
   ```bash
   open /workspace/CatholicMissal.xcodeproj
   ```

2. **Configure API endpoint**:
   - Open `Services/APIService.swift`
   - Update `baseURL` to point to your API server
   - For local development: `http://localhost:8000/api/v1`
   - For production: `https://your-api-domain.com/api/v1`

3. **Build and run**:
   - Select your target device or simulator
   - Press `Cmd+R` to build and run

### API Server Setup

Make sure the Catholic Missal API is running:

```bash
# In the workspace root
cd /workspace
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python run_dev.py
```

The API will be available at `http://localhost:8000`

## 📲 App Capabilities

### iOS Integration
- **Native Navigation**: SwiftUI navigation with smooth transitions
- **Tab Bar Interface**: Easy access to all sections
- **Pull to Refresh**: Refresh data in all views
- **Haptic Feedback**: Tactile feedback for interactions
- **Accessibility**: Full VoiceOver and accessibility support

### Notifications
- **Daily Reading Alerts**: Customizable time for daily reminders
- **Prayer Reminders**: Morning and evening prayer notifications
- **Feast Day Notifications**: Alerts for major liturgical celebrations
- **Badge Updates**: App icon badge for new content

### Offline Features
- **Core Data Storage**: Local database for readings and prayers
- **Cached Images**: Store any liturgical images locally
- **Favorites System**: Save favorite prayers without internet
- **Graceful Degradation**: App works offline with cached data

## 🎨 Design System

### Catholic Theme
- **Primary Color**: Catholic Red (#8B0000)
- **Accent Color**: Catholic Gold (#FFD700)
- **Liturgical Colors**: Proper colors for different seasons
- **Typography**: Readable fonts optimized for scripture

### User Experience
- **Intuitive Navigation**: Natural iOS patterns
- **Readable Text**: Optimized for scripture reading
- **Touch Targets**: Properly sized for mobile interaction
- **Loading States**: Beautiful loading indicators

## 🔧 Configuration

### App Settings
- **Bundle Identifier**: `com.catholicmissal.app`
- **Display Name**: "Catholic Missal"
- **Category**: Reference
- **Supported Orientations**: Portrait, Landscape
- **Minimum iOS**: 16.0

### Permissions Required
- **Notifications**: For daily reading and prayer reminders
- **Internet Access**: To fetch liturgical data from API

## 📱 Device Support

- **iPhone**: iOS 16.0+
- **iPad**: iPadOS 16.0+
- **Optimized for**: All screen sizes with responsive design

## 🧪 Testing

### Simulator Testing
1. Open Xcode
2. Select iOS Simulator
3. Build and run (`Cmd+R`)
4. Test all features with sample data

### Device Testing
1. Connect iOS device
2. Ensure developer account is configured
3. Build and run on device
4. Test notifications and offline features

## 🔄 API Integration

### Endpoints Used
- `GET /api/v1/calendar/today` - Today's liturgical info
- `GET /api/v1/calendar/{date}` - Specific date info
- `GET /api/v1/readings/today` - Today's readings
- `GET /api/v1/readings/{date}` - Readings for date
- `GET /api/v1/prayers/common` - Common prayers
- `GET /api/v1/prayers/category/{category}` - Category prayers
- `GET /api/v1/prayers/seasonal/{season}` - Seasonal prayers

### Error Handling
- **Network Errors**: Graceful fallback to cached data
- **API Errors**: User-friendly error messages
- **Timeout Handling**: 10-second timeout with retry options
- **Offline Mode**: Full functionality with stored data

## 🚀 Deployment

### App Store Preparation
1. **Update Bundle ID**: Set unique bundle identifier
2. **Add App Icons**: Create app icons for all sizes
3. **Configure Signing**: Set up development/distribution certificates
4. **Test on Device**: Thorough testing on real devices
5. **Submit for Review**: Follow App Store guidelines

### TestFlight Distribution
1. **Archive Build**: Product → Archive in Xcode
2. **Upload to App Store Connect**: Use Xcode Organizer
3. **Internal Testing**: Test with team members
4. **External Testing**: Beta testing with users

## 🎯 Key Benefits

### For Users
- **Native Performance**: Smooth, responsive iOS experience
- **Offline Access**: Read prayers and cached readings without internet
- **Notifications**: Never miss daily readings or prayer times
- **Beautiful Design**: Catholic-themed, reverent interface
- **Accessibility**: Full support for users with disabilities

### For Developers
- **Modern Swift**: Latest SwiftUI and iOS features
- **Clean Architecture**: MVVM pattern with proper separation
- **Type Safety**: Full Swift type system benefits
- **Testable**: Well-structured code for unit testing
- **Extensible**: Easy to add new features

## 📚 Next Steps

1. **Open in Xcode**: `open CatholicMissal.xcodeproj`
2. **Configure API**: Update endpoint in APIService.swift
3. **Test on Simulator**: Build and run for testing
4. **Customize Design**: Adjust colors, fonts, or layouts as needed
5. **Add App Icons**: Create beautiful app icons
6. **Test on Device**: Deploy to physical device for full testing

## 🙏 Spiritual Purpose

This iOS app is designed to support Catholic spiritual life by providing:
- **Daily Scripture**: Easy access to Mass readings
- **Liturgical Awareness**: Understanding of the Church calendar
- **Prayer Resources**: Traditional Catholic prayers
- **Mobile Devotion**: Spiritual resources always at hand

---

**Ad Majorem Dei Gloriam** - For the Greater Glory of God

Your Catholic Missal iOS app is ready for development and deployment! 📱🙏✨