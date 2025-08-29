#!/usr/bin/env python3
"""
Development server runner for Catholic Missal API.

This script provides an easy way to run the API during development.
"""

import uvicorn
import sys
import os

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

if __name__ == "__main__":
    print("🙏 Starting Catholic Missal API Development Server")
    print("📖 API Documentation: http://localhost:8000/docs")
    print("🌐 Welcome Page: http://localhost:8000")
    print("⛪ Ad Majorem Dei Gloriam")
    print("-" * 50)
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )