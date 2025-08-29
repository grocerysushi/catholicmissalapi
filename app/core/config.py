"""
Configuration settings for the Catholic Missal API.
"""

from pydantic import BaseSettings
from typing import List, Optional


class Settings(BaseSettings):
    """Application settings."""
    
    # API Configuration
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Catholic Missal API"
    VERSION: str = "1.0.0"
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]
    
    # Data Sources Configuration
    USCCB_BASE_URL: str = "https://bible.usccb.org"
    VATICAN_BASE_URL: str = "https://www.vatican.va"
    
    # Rate Limiting (requests per minute)
    RATE_LIMIT_REQUESTS: int = 60
    
    # Cache Settings (in seconds)
    CACHE_EXPIRE_TIME: int = 3600  # 1 hour
    READINGS_CACHE_TIME: int = 86400  # 24 hours
    CALENDAR_CACHE_TIME: int = 86400  # 24 hours
    
    # Database (if needed for caching/storage)
    DATABASE_URL: Optional[str] = "sqlite:///./catholic_missal.db"
    
    # Logging
    LOG_LEVEL: str = "INFO"
    
    # User Agent for web scraping (respectful identification)
    USER_AGENT: str = "Catholic-Missal-API/1.0 (Educational/Religious Use)"
    
    # Request timeout (seconds)
    REQUEST_TIMEOUT: int = 30
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()