# Catholic Missal App

A modern, responsive web application for accessing Catholic liturgical data including daily Mass readings, liturgical calendar information, and traditional prayers.

## Features

- **Daily Mass Readings**: View scripture readings for any date with beautiful typography
- **Liturgical Calendar**: Interactive calendar showing liturgical seasons, feast days, and celebrations
- **Prayer Collection**: Browse traditional Catholic prayers organized by category
- **Responsive Design**: Works beautifully on desktop, tablet, and mobile devices
- **Print Support**: Print-friendly layouts for readings and prayers
- **Accessibility**: Full keyboard navigation and screen reader support

## Technology Stack

- **Frontend**: React 18 with TypeScript
- **Styling**: Tailwind CSS with custom Catholic-themed design
- **Routing**: React Router DOM
- **Icons**: Lucide React
- **API**: Catholic Missal API (FastAPI backend)
- **Date Handling**: date-fns library

## Getting Started

### Prerequisites

- Node.js (version 16 or higher)
- npm or yarn package manager
- Catholic Missal API running on localhost:8000

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd missal-app
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. Open [http://localhost:3000](http://localhost:3000) to view the app in your browser.

### API Setup

Make sure the Catholic Missal API is running on port 8000:

```bash
cd ../
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Or using Docker:

```bash
docker-compose up -d
```

## Available Scripts

- `npm start` - Runs the app in development mode
- `npm test` - Launches the test runner
- `npm run build` - Builds the app for production
- `npm run eject` - Ejects from Create React App (one-way operation)

## Project Structure

```
src/
├── components/
│   ├── Calendar/
│   │   └── LiturgicalCalendar.tsx
│   ├── Layout/
│   │   ├── Header.tsx
│   │   └── Footer.tsx
│   ├── Prayers/
│   │   └── PrayersSection.tsx
│   ├── Readings/
│   │   └── DailyReadings.tsx
│   └── UI/
│       ├── ErrorMessage.tsx
│       └── LoadingSpinner.tsx
├── services/
│   └── api.ts
├── App.tsx
├── index.tsx
└── index.css
```

## Features in Detail

### Daily Readings
- Navigate between dates using arrow buttons
- Quick navigation to today, tomorrow, and next Sunday
- Print-friendly layout for readings
- Scripture references and citations
- Responsorial psalm with refrain
- Gospel acclamation display

### Liturgical Calendar
- Monthly calendar view with liturgical colors
- Click on any date to view celebrations and details
- Color-coded liturgical seasons
- Icons for solemnities and feasts
- Modal popup with detailed liturgical information

### Prayers Section
- Categorized prayer collections (Common, Marian, Penitential, Eucharistic)
- Seasonal prayers for Advent, Christmas, Lent, Easter
- Search functionality across all prayers
- Expandable prayer cards
- Beautiful typography for prayer text

## Customization

### Themes
The app uses a Catholic-themed color palette defined in `tailwind.config.js`:
- Catholic Red: `#8B0000`
- Catholic Gold: `#FFD700`
- Liturgical colors for different seasons

### API Configuration
Update the API base URL in `src/services/api.ts` for production deployment.

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Accessibility

The app includes:
- Semantic HTML structure
- ARIA labels and roles
- Keyboard navigation support
- Screen reader compatibility
- High contrast mode support
- Reduced motion preferences

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Guidelines
- Respect Catholic teaching and tradition
- Maintain liturgical accuracy
- Follow accessibility best practices
- Provide proper attribution for sources

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Copyright Notice

This app respects all copyright and licensing requirements. Liturgical texts are used in accordance with Church policies and fair use guidelines. For commercial use, please ensure proper licensing from source authorities.

## Acknowledgments

- **USCCB** - For liturgical resources
- **Vatican** - For official Church documents
- **Catholic Publishers** - For liturgical texts
- **Open Source Community** - For the tools and libraries

---

*Ad Majorem Dei Gloriam* - For the Greater Glory of God