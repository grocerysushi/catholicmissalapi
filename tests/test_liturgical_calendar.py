"""
Tests for liturgical calendar calculations.
"""

import pytest
from datetime import date, timedelta
from app.services.liturgical_calendar import LiturgicalCalendar
from app.models.liturgical import LiturgicalSeason, LiturgicalRank


class TestLiturgicalCalendar:
    """Test liturgical calendar calculations."""
    
    def test_easter_calculation_2024(self):
        """Test Easter calculation for 2024."""
        calendar = LiturgicalCalendar(2024)
        easter = calendar.easter_date
        # Easter 2024 is March 31
        assert easter == date(2024, 3, 31)
    
    def test_easter_calculation_2025(self):
        """Test Easter calculation for 2025."""
        calendar = LiturgicalCalendar(2025)
        easter = calendar.easter_date
        # Easter 2025 is April 20
        assert easter == date(2025, 4, 20)
    
    def test_advent_calculation_2024(self):
        """Test Advent start calculation for 2024."""
        calendar = LiturgicalCalendar(2024)
        advent = calendar.advent_start
        # First Sunday of Advent 2024 is December 1
        assert advent == date(2024, 12, 1)
    
    def test_liturgical_seasons(self):
        """Test liturgical season detection."""
        calendar = LiturgicalCalendar(2024)
        
        # Test Christmas season
        christmas_day = date(2024, 12, 25)
        season, week = calendar.get_liturgical_season(christmas_day)
        assert season == LiturgicalSeason.CHRISTMAS
        
        # Test Advent
        advent_day = date(2024, 12, 15)
        season, week = calendar.get_liturgical_season(advent_day)
        assert season == LiturgicalSeason.ADVENT
        
        # Test Lent
        ash_wednesday = calendar.easter_date - timedelta(days=46)
        season, week = calendar.get_liturgical_season(ash_wednesday)
        assert season == LiturgicalSeason.LENT
        
        # Test Easter
        easter_monday = calendar.easter_date + timedelta(days=1)
        season, week = calendar.get_liturgical_season(easter_monday)
        assert season == LiturgicalSeason.EASTER
    
    def test_fixed_celebrations(self):
        """Test fixed date celebrations."""
        calendar = LiturgicalCalendar(2024)
        
        # Test Christmas
        christmas = date(2024, 12, 25)
        celebrations = calendar.get_fixed_celebrations(christmas)
        assert len(celebrations) == 1
        assert celebrations[0].name == "Nativity of the Lord"
        assert celebrations[0].rank == LiturgicalRank.SOLEMNITY
        
        # Test Epiphany
        epiphany = date(2024, 1, 6)
        celebrations = calendar.get_fixed_celebrations(epiphany)
        assert len(celebrations) == 1
        assert celebrations[0].name == "Epiphany of the Lord"
    
    def test_movable_celebrations(self):
        """Test movable celebrations based on Easter."""
        calendar = LiturgicalCalendar(2024)
        
        # Test Easter Sunday
        easter = calendar.easter_date
        celebrations = calendar.get_movable_celebrations(easter)
        assert len(celebrations) == 1
        assert celebrations[0].name == "Easter Sunday"
        assert celebrations[0].rank == LiturgicalRank.SOLEMNITY
        
        # Test Palm Sunday
        palm_sunday = easter - timedelta(days=7)
        celebrations = calendar.get_movable_celebrations(palm_sunday)
        assert len(celebrations) == 1
        assert celebrations[0].name == "Palm Sunday"
    
    def test_liturgical_day(self):
        """Test complete liturgical day calculation."""
        calendar = LiturgicalCalendar(2024)
        
        # Test a regular day
        regular_day = date(2024, 6, 15)  # Should be Ordinary Time
        liturgical_day = calendar.get_liturgical_day(regular_day)
        
        assert liturgical_day.date == regular_day
        assert liturgical_day.season == LiturgicalSeason.ORDINARY_TIME
        assert liturgical_day.weekday == "Saturday"
        
        # Test Christmas
        christmas = date(2024, 12, 25)
        liturgical_day = calendar.get_liturgical_day(christmas)
        
        assert liturgical_day.date == christmas
        assert liturgical_day.season == LiturgicalSeason.CHRISTMAS
        assert len(liturgical_day.celebrations) >= 1
        assert liturgical_day.primary_celebration.name == "Nativity of the Lord"


if __name__ == "__main__":
    pytest.main([__file__])