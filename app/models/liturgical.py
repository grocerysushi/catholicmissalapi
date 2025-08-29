"""
Data models for liturgical information.
"""

from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import Optional, List, Dict, Any
from enum import Enum


class LiturgicalSeason(str, Enum):
    """Liturgical seasons of the Catholic Church."""
    ADVENT = "Advent"
    CHRISTMAS = "Christmas"
    ORDINARY_TIME = "Ordinary Time"
    LENT = "Lent"
    EASTER_TRIDUUM = "Easter Triduum"
    EASTER = "Easter"


class LiturgicalRank(str, Enum):
    """Liturgical ranks for celebrations."""
    SOLEMNITY = "Solemnity"
    FEAST = "Feast"
    MEMORIAL = "Memorial"
    OPTIONAL_MEMORIAL = "Optional Memorial"
    WEEKDAY = "Weekday"
    SUNDAY = "Sunday"


class LiturgicalColor(str, Enum):
    """Liturgical colors for vestments."""
    WHITE = "White"
    RED = "Red"
    GREEN = "Green"
    PURPLE = "Purple"
    ROSE = "Rose"
    BLACK = "Black"


class Reading(BaseModel):
    """A single scripture reading."""
    reference: str = Field(..., description="Scripture reference (e.g., 'Genesis 1:1-5')")
    citation: str = Field(..., description="Short citation (e.g., 'Gn 1:1-5')")
    text: Optional[str] = Field(None, description="Full text of the reading")
    short_text: Optional[str] = Field(None, description="Abbreviated text")
    source: str = Field(..., description="Source of the reading data")


class Psalm(BaseModel):
    """Responsorial psalm."""
    reference: str = Field(..., description="Psalm reference")
    refrain: Optional[str] = Field(None, description="Psalm refrain")
    verses: Optional[List[str]] = Field(None, description="Psalm verses")
    source: str = Field(..., description="Source of the psalm data")


class DailyReadings(BaseModel):
    """Complete set of readings for a day."""
    date: date = Field(..., description="Date for these readings")
    first_reading: Optional[Reading] = Field(None, description="First reading")
    responsorial_psalm: Optional[Psalm] = Field(None, description="Responsorial psalm")
    second_reading: Optional[Reading] = Field(None, description="Second reading (Sundays/Solemnities)")
    gospel_acclamation: Optional[str] = Field(None, description="Gospel acclamation")
    gospel: Optional[Reading] = Field(None, description="Gospel reading")
    source: str = Field(..., description="Primary source of the readings")
    last_updated: datetime = Field(default_factory=datetime.utcnow)


class Celebration(BaseModel):
    """A liturgical celebration."""
    name: str = Field(..., description="Name of the celebration")
    rank: LiturgicalRank = Field(..., description="Liturgical rank")
    color: LiturgicalColor = Field(..., description="Liturgical color")
    description: Optional[str] = Field(None, description="Description of the celebration")
    proper_readings: bool = Field(False, description="Whether this celebration has proper readings")


class LiturgicalDay(BaseModel):
    """Complete liturgical information for a specific day."""
    date: date = Field(..., description="Calendar date")
    season: LiturgicalSeason = Field(..., description="Liturgical season")
    season_week: Optional[int] = Field(None, description="Week number in the season")
    weekday: str = Field(..., description="Day of the week")
    celebrations: List[Celebration] = Field(default_factory=list, description="Celebrations for this day")
    primary_celebration: Optional[Celebration] = Field(None, description="Primary celebration")
    color: LiturgicalColor = Field(..., description="Liturgical color for the day")
    readings: Optional[DailyReadings] = Field(None, description="Scripture readings")
    source: str = Field(..., description="Source of the liturgical data")
    last_updated: datetime = Field(default_factory=datetime.utcnow)


class Prayer(BaseModel):
    """A liturgical prayer."""
    name: str = Field(..., description="Name of the prayer")
    category: str = Field(..., description="Category (e.g., 'Opening Prayer', 'Prayer over Offerings')")
    text: str = Field(..., description="Text of the prayer")
    source: str = Field(..., description="Source of the prayer")
    language: str = Field(default="en", description="Language code")
    copyright_notice: Optional[str] = Field(None, description="Copyright information")


class MissalPart(BaseModel):
    """Part of the Mass from the Missal."""
    name: str = Field(..., description="Name of the part")
    category: str = Field(..., description="Category (e.g., 'Ordinary', 'Proper')")
    text: str = Field(..., description="Text content")
    rubrics: Optional[str] = Field(None, description="Liturgical instructions")
    source: str = Field(..., description="Source of the text")
    copyright_notice: Optional[str] = Field(None, description="Copyright information")