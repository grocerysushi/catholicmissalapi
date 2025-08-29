"""
Catholic Missal API

A comprehensive API for accessing Catholic liturgical data including:
- Daily Mass readings
- Liturgical calendar
- Feast days and celebrations
- Prayer texts (where permitted)

Sources:
- USCCB (United States Conference of Catholic Bishops)
- Vatican Official Sources
- Licensed Catholic Publishers
- Academic Institutions

Note: This API respects copyright and licensing requirements.
All liturgical texts are used in accordance with Church policies.
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
import uvicorn
from datetime import datetime, date
from typing import Optional, List

from .routers import calendar, readings, prayers
from .models.responses import APIInfo
from .core.config import settings

app = FastAPI(
    title="Catholic Missal API",
    description=__doc__,
    version="1.0.0",
    contact={
        "name": "Catholic Missal API",
        "url": "https://github.com/yourusername/catholic-missal-api",
    },
    license_info={
        "name": "MIT",
        "url": "https://opensource.org/licenses/MIT",
    },
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(calendar.router, prefix="/api/v1/calendar", tags=["Calendar"])
app.include_router(readings.router, prefix="/api/v1/readings", tags=["Readings"])
app.include_router(prayers.router, prefix="/api/v1/prayers", tags=["Prayers"])

@app.get("/", response_class=HTMLResponse)
async def root():
    """Welcome page with API information."""
    return """
    <html>
        <head>
            <title>Catholic Missal API</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; }
                .header { color: #8B0000; }
                .section { margin: 20px 0; }
                .endpoint { background-color: #f5f5f5; padding: 10px; margin: 5px 0; }
                .copyright { font-size: 12px; color: #666; margin-top: 30px; }
            </style>
        </head>
        <body>
            <h1 class="header">Catholic Missal API</h1>
            <p>Welcome to the Catholic Missal API - your gateway to Catholic liturgical data.</p>
            
            <div class="section">
                <h2>Available Endpoints:</h2>
                <div class="endpoint"><strong>GET /docs</strong> - Interactive API documentation</div>
                <div class="endpoint"><strong>GET /api/v1/calendar/today</strong> - Today's liturgical information</div>
                <div class="endpoint"><strong>GET /api/v1/readings/today</strong> - Today's Mass readings</div>
                <div class="endpoint"><strong>GET /api/v1/calendar/{date}</strong> - Liturgical info for specific date</div>
            </div>
            
            <div class="section">
                <h2>Data Sources:</h2>
                <ul>
                    <li>USCCB (United States Conference of Catholic Bishops)</li>
                    <li>Vatican Official Sources</li>
                    <li>Licensed Catholic Publishers</li>
                    <li>Academic Institutions</li>
                </ul>
            </div>
            
            <div class="copyright">
                <p><strong>Copyright Notice:</strong> This API respects all copyright and licensing requirements. 
                Liturgical texts are used in accordance with Church policies and fair use guidelines. 
                For commercial use, please ensure proper licensing.</p>
            </div>
        </body>
    </html>
    """

@app.get("/api/v1/info", response_model=APIInfo)
async def get_api_info():
    """Get API information and status."""
    return APIInfo(
        name="Catholic Missal API",
        version="1.0.0",
        description="API for Catholic liturgical data",
        sources=[
            "USCCB (United States Conference of Catholic Bishops)",
            "Vatican Official Sources", 
            "Licensed Catholic Publishers",
            "Academic Institutions"
        ],
        endpoints=[
            "/api/v1/calendar/today",
            "/api/v1/readings/today", 
            "/api/v1/calendar/{date}",
            "/api/v1/readings/{date}"
        ]
    )

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)