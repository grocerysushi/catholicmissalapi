# Catholic Missal API

A comprehensive REST API for accessing Catholic liturgical data including daily Mass readings, liturgical calendar information, and prayers.

## 🙏 Purpose

This API provides programmatic access to Catholic liturgical information to support:
- Catholic mobile and web applications
- Parish websites and digital ministries
- Educational and research projects
- Personal devotional tools

## ✨ Features

- **Daily Mass Readings**: Scripture readings for any date
- **Liturgical Calendar**: Complete liturgical year calculations
- **Feast Days & Celebrations**: Solemnities, feasts, and memorials
- **Seasonal Information**: Advent, Christmas, Lent, Easter, Ordinary Time
- **Prayer Collection**: Traditional Catholic prayers by category
- **Multiple Data Sources**: USCCB, Vatican, and other official sources

## 📊 Data Sources

This API respectfully aggregates data from official Catholic sources:

- **USCCB** (United States Conference of Catholic Bishops) - Primary source for US liturgical data
- **Vatican Official Sources** - Universal Church documents and texts
- **Catholic Publishers** - Licensed liturgical materials
- **Academic Institutions** - Research databases and scholarly resources

## 🚀 Quick Start

### Using Docker (Recommended)

```bash
# Clone the repository
git clone <repository-url>
cd catholic-missal-api

# Start the API
docker-compose up -d

# API will be available at http://localhost:8000
```

### Manual Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Run the API
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## 📖 API Documentation

Once running, visit:
- **Interactive Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Welcome Page**: http://localhost:8000

## 🔗 Key Endpoints

### Calendar Endpoints
- `GET /api/v1/calendar/today` - Today's liturgical information
- `GET /api/v1/calendar/{date}` - Specific date (YYYY-MM-DD format)
- `GET /api/v1/calendar/season/{year}` - Key liturgical dates for a year

### Readings Endpoints
- `GET /api/v1/readings/today` - Today's Mass readings
- `GET /api/v1/readings/{date}` - Readings for specific date
- `GET /api/v1/readings/range/{start}/{end}` - Readings for date range (max 31 days)

### Prayers Endpoints
- `GET /api/v1/prayers/common` - Common Catholic prayers
- `GET /api/v1/prayers/category/{category}` - Prayers by category (marian, penitential, eucharistic)
- `GET /api/v1/prayers/seasonal/{season}` - Seasonal prayers (advent, christmas, lent, easter)

## 📝 Example Usage

### Get Today's Liturgical Information
```bash
curl http://localhost:8000/api/v1/calendar/today
```

### Get Christmas Day Information
```bash
curl http://localhost:8000/api/v1/calendar/2024-12-25
```

### Get Today's Mass Readings
```bash
curl http://localhost:8000/api/v1/readings/today
```

### Get Common Prayers
```bash
curl http://localhost:8000/api/v1/prayers/common
```

## 📋 Response Format

All endpoints return JSON with consistent structure:

```json
{
  "success": true,
  "liturgical_day": {
    "date": "2024-12-25",
    "season": "Christmas",
    "weekday": "Wednesday",
    "celebrations": [...],
    "color": "White"
  },
  "source_attribution": "Data sources: USCCB, Vatican Official Sources..."
}
```

## ⚖️ Copyright & Licensing

This API respects all copyright and licensing requirements:

- **Traditional Prayers**: Public domain content
- **USCCB Content**: Used in accordance with fair use guidelines for educational/religious purposes
- **Vatican Content**: Official documents used with proper attribution
- **Commercial Use**: Additional licensing may be required - consult source policies

### Important Notes
- This API is intended for educational and religious use
- Commercial applications should verify licensing requirements
- All content includes proper source attribution
- Rate limiting is implemented to respect source websites

## 🛠️ Technical Details

### Built With
- **FastAPI** - Modern Python web framework
- **Pydantic** - Data validation and serialization
- **httpx** - Async HTTP client for data fetching
- **BeautifulSoup** - HTML parsing for web scraping
- **SQLAlchemy** - Database ORM (optional caching)

### Architecture
- **Modular Design**: Separate services for calendar calculations and data sources
- **Async/Await**: Non-blocking I/O for better performance
- **Caching**: Intelligent caching to reduce external API calls
- **Error Handling**: Graceful fallbacks and comprehensive error responses

### Configuration
Copy `.env.example` to `.env` and customize settings:

```env
# Data source URLs
USCCB_BASE_URL=https://bible.usccb.org
VATICAN_BASE_URL=https://www.vatican.va

# Cache settings
CACHE_EXPIRE_TIME=3600
READINGS_CACHE_TIME=86400

# Rate limiting
RATE_LIMIT_REQUESTS=60
```

## 🧪 Testing

```bash
# Run tests
pytest tests/

# Run with coverage
pytest tests/ --cov=app
```

## 🤝 Contributing

We welcome contributions that help improve this API while respecting Catholic teaching and copyright laws:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Guidelines
- Respect copyright and licensing requirements
- Maintain accuracy of liturgical information
- Follow Catholic Church teachings and traditions
- Provide proper attribution for all sources

## 📧 Support

For questions, issues, or suggestions:
- Open an issue on GitHub
- Check the documentation at `/docs`
- Review the FAQ section

## 🙏 Acknowledgments

- **USCCB** - For providing comprehensive liturgical resources
- **Vatican** - For official Church documents and guidance
- **Catholic Publishers** - For liturgical texts and materials
- **Academic Institutions** - For research and scholarly resources
- **Open Source Community** - For the tools and libraries that make this possible

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

*Ad Majorem Dei Gloriam* - For the Greater Glory of God
