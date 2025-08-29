"""
Calendar endpoints for liturgical calendar information.
"""

from fastapi import APIRouter, HTTPException, Depends
from datetime import datetime, date
from typing import Optional

from ..models.responses import CalendarResponse, ErrorResponse
from ..services.data_sources import DataSourceManager
from ..services.liturgical_calendar import LiturgicalCalendar

router = APIRouter()

# Global data source manager
data_manager = DataSourceManager()


async def get_data_manager():
    """Dependency to get the data source manager."""
    return data_manager


@router.get("/today", response_model=CalendarResponse)
async def get_today_calendar(
    manager: DataSourceManager = Depends(get_data_manager)
):
    """Get liturgical calendar information for today."""
    today = date.today()
    return await get_calendar_for_date(today, manager)


@router.get("/{date_str}", response_model=CalendarResponse)
async def get_calendar_for_date_endpoint(
    date_str: str,
    manager: DataSourceManager = Depends(get_data_manager)
):
    """
    Get liturgical calendar information for a specific date.
    
    Date format: YYYY-MM-DD (e.g., 2024-12-25)
    """
    try:
        target_date = datetime.strptime(date_str, "%Y-%m-%d").date()
        return await get_calendar_for_date(target_date, manager)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid date format. Use YYYY-MM-DD (e.g., 2024-12-25)"
        )


async def get_calendar_for_date(
    target_date: date,
    manager: DataSourceManager
) -> CalendarResponse:
    """Get liturgical calendar information for a specific date."""
    try:
        liturgical_day = await manager.get_liturgical_day(target_date)
        
        return CalendarResponse(
            liturgical_day=liturgical_day,
            source_attribution=(
                "Data sources: USCCB (United States Conference of Catholic Bishops), "
                "Vatican Official Sources, Catholic Missal API Liturgical Calculator. "
                "Used in accordance with fair use and educational purposes."
            )
        )
    
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving liturgical calendar information: {str(e)}"
        )


@router.get("/season/{year}", response_model=dict)
async def get_liturgical_year(year: int):
    """
    Get key dates for a liturgical year.
    
    Returns important dates like Easter, Advent start, etc.
    """
    try:
        calendar = LiturgicalCalendar(year)
        
        key_dates = {
            "year": year,
            "easter": calendar.easter_date.isoformat(),
            "advent_start": calendar.advent_start.isoformat(),
            "ash_wednesday": (calendar.easter_date.replace(day=calendar.easter_date.day - 46)).isoformat(),
            "palm_sunday": (calendar.easter_date.replace(day=calendar.easter_date.day - 7)).isoformat(),
            "good_friday": (calendar.easter_date.replace(day=calendar.easter_date.day - 2)).isoformat(),
            "pentecost": (calendar.easter_date.replace(day=calendar.easter_date.day + 49)).isoformat(),
            "christ_the_king": None,  # Would need calculation
        }
        
        return {
            "success": True,
            "data": key_dates,
            "source_attribution": "Catholic Missal API Liturgical Calculator"
        }
    
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error calculating liturgical year: {str(e)}"
        )


@router.on_event("shutdown")
async def shutdown_event():
    """Clean up resources on shutdown."""
    await data_manager.close()