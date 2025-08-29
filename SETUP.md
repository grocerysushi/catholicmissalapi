# Catholic Missal App Setup Guide

This guide will help you set up and run the Catholic Missal App, which consists of a FastAPI backend and a React frontend.

## 📋 Prerequisites

- **Python 3.8+** - For the API backend
- **Node.js 16+** - For the React frontend  
- **npm** - Node package manager
- **Git** - For version control (optional)

## 🚀 Quick Start

### Option 1: Use the Startup Script (Recommended)

1. Navigate to the project directory:
   ```bash
   cd /workspace
   ```

2. Run the startup script:
   ```bash
   ./start-missal-app.sh
   ```

This script will:
- Check all dependencies
- Set up Python virtual environment
- Install Python dependencies
- Start the API server on port 8000
- Install Node.js dependencies  
- Start the React frontend on port 3000
- Open both services automatically

### Option 2: Manual Setup

#### Backend Setup (API)

1. Create and activate a Python virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Start the API server:
   ```bash
   python run_dev.py
   ```
   
   Or using uvicorn directly:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

4. Verify the API is running:
   - Visit: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

#### Frontend Setup (React App)

1. Navigate to the frontend directory:
   ```bash
   cd missal-app
   ```

2. Install Node.js dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. The app will open at http://localhost:3000

## 🐳 Docker Setup (Alternative)

If you prefer using Docker:

1. Start the API with Docker:
   ```bash
   docker-compose up -d
   ```

2. The API will be available at http://localhost:8000

3. For the frontend, still use npm:
   ```bash
   cd missal-app
   npm install
   npm start
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the frontend directory:

```bash
cp missal-app/.env.example missal-app/.env
```

Edit the `.env` file to match your setup:
```
REACT_APP_API_BASE_URL=http://localhost:8000
```

### API Configuration

The API configuration can be found in `app/core/config.py`. Default settings should work for local development.

## 📱 Accessing the Application

Once both servers are running:

- **Frontend (Main App)**: http://localhost:3000
- **API Backend**: http://localhost:8000  
- **API Documentation**: http://localhost:8000/docs
- **Alternative API Docs**: http://localhost:8000/redoc

## 🎯 Features Overview

### Daily Readings
- View Mass readings for any date
- Navigate between days easily
- Print-friendly layouts
- Scripture references and citations

### Liturgical Calendar  
- Interactive monthly calendar
- Color-coded liturgical seasons
- Feast days and celebrations
- Detailed liturgical information

### Prayers Collection
- Traditional Catholic prayers
- Organized by categories
- Search functionality
- Seasonal prayers

## 🛠 Development

### Frontend Development
```bash
cd missal-app
npm start          # Development server
npm test           # Run tests
npm run build      # Production build
```

### Backend Development
```bash
source venv/bin/activate
python run_dev.py  # Development server with auto-reload
pytest tests/      # Run tests (if available)
```

## 📚 API Endpoints

Key API endpoints:

- `GET /api/v1/calendar/today` - Today's liturgical info
- `GET /api/v1/calendar/{date}` - Specific date info
- `GET /api/v1/readings/today` - Today's readings
- `GET /api/v1/readings/{date}` - Readings for date
- `GET /api/v1/prayers/common` - Common prayers
- `GET /api/v1/prayers/category/{category}` - Prayers by category

## 🔍 Troubleshooting

### Common Issues

1. **API not starting**:
   - Check Python version: `python3 --version`
   - Ensure all dependencies are installed: `pip install -r requirements.txt`
   - Check port 8000 is not in use: `lsof -i :8000`

2. **Frontend not starting**:
   - Check Node.js version: `node --version`
   - Clear npm cache: `npm cache clean --force`
   - Delete node_modules and reinstall: `rm -rf node_modules && npm install`

3. **API connection errors**:
   - Verify API is running on port 8000
   - Check CORS settings in the API
   - Ensure frontend proxy is configured correctly

4. **Missing data**:
   - The API fetches data from external sources
   - Some endpoints may have limited sample data
   - Check API logs for external service issues

### Logs and Debugging

- **API Logs**: Check the terminal where the API is running
- **Frontend Logs**: Check browser console (F12)
- **Network Issues**: Use browser Network tab to debug API calls

## 📞 Support

For issues and questions:

1. Check the API documentation at http://localhost:8000/docs
2. Review the browser console for frontend errors
3. Check the terminal output for backend errors
4. Ensure all dependencies are properly installed

## 🙏 Usage Notes

This application is designed for:
- Personal devotional use
- Parish and educational purposes
- Catholic liturgical reference

All liturgical texts are used in accordance with Church policies and fair use guidelines.

---

*Ad Majorem Dei Gloriam* - For the Greater Glory of God