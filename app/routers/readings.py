"""
Readings endpoints for daily Mass readings.
"""

from fastapi import APIRouter, HTTPException, Depends
from datetime import datetime, date, timedelta
from typing import Optional

from ..models.responses import ReadingsResponse, ErrorResponse
from ..services.data_sources import DataSourceManager

router = APIRouter()

# Global data source manager
data_manager = DataSourceManager()


async def get_data_manager():
    """Dependency to get the data source manager."""
    return data_manager


@router.get("/today", response_model=ReadingsResponse)
async def get_today_readings(
    manager: DataSourceManager = Depends(get_data_manager)
):
    """Get Mass readings for today."""
    today = date.today()
    return await get_readings_for_date(today, manager)


@router.get("/{date_str}", response_model=ReadingsResponse)
async def get_readings_for_date_endpoint(
    date_str: str,
    manager: DataSourceManager = Depends(get_data_manager)
):
    """
    Get Mass readings for a specific date.
    
    Date format: YYYY-MM-DD (e.g., 2024-12-25)
    """
    try:
        target_date = datetime.strptime(date_str, "%Y-%m-%d").date()
        return await get_readings_for_date(target_date, manager)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid date format. Use YYYY-MM-DD (e.g., 2024-12-25)"
        )


async def get_readings_for_date(
    target_date: date,
    manager: DataSourceManager
) -> ReadingsResponse:
    """Get Mass readings for a specific date."""
    try:
        readings = await manager.get_daily_readings(target_date)
        
        if not readings:
            # Create a basic readings object with just the date
            from ..models.liturgical import DailyReadings
            readings = DailyReadings(
                date=target_date,
                source="No readings available for this date",
                last_updated=datetime.utcnow()
            )
        
        return ReadingsResponse(
            readings=readings,
            source_attribution=(
                "Readings sourced from USCCB (United States Conference of Catholic Bishops) "
                "and other official Catholic sources. Used in accordance with fair use "
                "and educational purposes. For commercial use, please ensure proper licensing."
            )
        )
    
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving readings: {str(e)}"
        )


@router.get("/range/{start_date}/{end_date}", response_model=dict)
async def get_readings_range(
    start_date: str,
    end_date: str,
    manager: DataSourceManager = Depends(get_data_manager)
):
    """
    Get Mass readings for a date range.
    
    Date format: YYYY-MM-DD (e.g., 2024-12-25)
    Limited to 31 days maximum.
    """
    try:
        start = datetime.strptime(start_date, "%Y-%m-%d").date()
        end = datetime.strptime(end_date, "%Y-%m-%d").date()
        
        # Limit range to prevent abuse
        if (end - start).days > 31:
            raise HTTPException(
                status_code=400,
                detail="Date range cannot exceed 31 days"
            )
        
        if start > end:
            raise HTTPException(
                status_code=400,
                detail="Start date must be before or equal to end date"
            )
        
        readings_list = []
        current_date = start
        
        while current_date <= end:
            readings = await manager.get_daily_readings(current_date)
            if readings:
                readings_list.append(readings)
            current_date = current_date + timedelta(days=1)
        
        return {
            "success": True,
            "start_date": start_date,
            "end_date": end_date,
            "readings": [reading.dict() for reading in readings_list],
            "source_attribution": (
                "Readings sourced from USCCB and other official Catholic sources. "
                "Used in accordance with fair use and educational purposes."
            )
        }
    
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid date format. Use YYYY-MM-DD (e.g., 2024-12-25)"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error retrieving readings range: {str(e)}"
        )


@router.on_event("shutdown")
async def shutdown_event():
    """Clean up resources on shutdown."""
    await data_manager.close()