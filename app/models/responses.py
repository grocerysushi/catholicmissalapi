"""
Response models for the API.
"""

from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import List, Optional, Dict, Any
from .liturgical import LiturgicalDay, DailyReadings, Prayer, MissalPart


class APIInfo(BaseModel):
    """API information response."""
    name: str = Field(..., description="API name")
    version: str = Field(..., description="API version")
    description: str = Field(..., description="API description")
    sources: List[str] = Field(..., description="Data sources")
    endpoints: List[str] = Field(..., description="Available endpoints")


class ErrorResponse(BaseModel):
    """Error response model."""
    error: str = Field(..., description="Error message")
    detail: Optional[str] = Field(None, description="Detailed error information")
    timestamp: datetime = Field(default_factory=datetime.utcnow)


class SuccessResponse(BaseModel):
    """Generic success response."""
    success: bool = Field(True, description="Success status")
    message: str = Field(..., description="Success message")
    data: Optional[Dict[str, Any]] = Field(None, description="Response data")


class CalendarResponse(BaseModel):
    """Calendar endpoint response."""
    liturgical_day: LiturgicalDay = Field(..., description="Liturgical day information")
    success: bool = Field(True)
    source_attribution: str = Field(..., description="Data source attribution")


class ReadingsResponse(BaseModel):
    """Readings endpoint response."""
    readings: DailyReadings = Field(..., description="Daily readings")
    success: bool = Field(True)
    source_attribution: str = Field(..., description="Data source attribution")


class PrayersResponse(BaseModel):
    """Prayers endpoint response."""
    prayers: List[Prayer] = Field(..., description="List of prayers")
    success: bool = Field(True)
    source_attribution: str = Field(..., description="Data source attribution")


class MissalResponse(BaseModel):
    """Missal parts response."""
    parts: List[MissalPart] = Field(..., description="Missal parts")
    success: bool = Field(True)
    source_attribution: str = Field(..., description="Data source attribution")