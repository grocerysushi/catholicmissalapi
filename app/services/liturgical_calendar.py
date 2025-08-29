"""
Liturgical calendar calculation service.

This module calculates the Roman Catholic liturgical calendar,
including movable feasts, seasons, and liturgical colors.
"""

from datetime import datetime, date, timedelta
from typing import Dict, List, Optional, Tuple
import calendar

from ..models.liturgical import (
    LiturgicalSeason, LiturgicalRank, LiturgicalColor, 
    Celebration, LiturgicalDay
)


class LiturgicalCalendar:
    """Roman Catholic liturgical calendar calculator."""
    
    def __init__(self, year: int):
        self.year = year
        self._easter_date = None
        self._advent_start = None
        
    @property
    def easter_date(self) -> date:
        """Calculate Easter date for the given year using the Western algorithm."""
        if self._easter_date is None:
            self._easter_date = self._calculate_easter()
        return self._easter_date
    
    def _calculate_easter(self) -> date:
        """
        Calculate Easter date using the algorithm for Western Christianity.
        Based on the Gregorian calendar.
        """
        year = self.year
        
        # Calculate Easter using the standard algorithm
        a = year % 19
        b = year // 100
        c = year % 100
        d = b // 4
        e = b % 4
        f = (b + 8) // 25
        g = (b - f + 1) // 3
        h = (19 * a + b - d - g + 15) % 30
        i = c // 4
        k = c % 4
        l = (32 + 2 * e + 2 * i - h - k) % 7
        m = (a + 11 * h + 22 * l) // 451
        month = (h + l - 7 * m + 114) // 31
        day = ((h + l - 7 * m + 114) % 31) + 1
        
        return date(year, month, day)
    
    @property
    def advent_start(self) -> date:
        """Calculate the first Sunday of Advent."""
        if self._advent_start is None:
            # First Sunday of Advent is 4 Sundays before Christmas
            christmas = date(self.year, 12, 25)
            days_to_sunday = (christmas.weekday() + 1) % 7
            fourth_sunday_before = christmas - timedelta(days=days_to_sunday + 21)
            self._advent_start = fourth_sunday_before
        return self._advent_start
    
    def get_liturgical_season(self, target_date: date) -> Tuple[LiturgicalSeason, Optional[int]]:
        """
        Determine the liturgical season and week for a given date.
        Returns (season, week_number).
        """
        easter = self.easter_date
        
        # Christmas Season (Dec 25 - Baptism of the Lord)
        christmas = date(target_date.year, 12, 25)
        if target_date >= christmas:
            # Check if we're still in Christmas season of this year
            next_year_calendar = LiturgicalCalendar(target_date.year + 1)
            baptism_of_lord = next_year_calendar._get_baptism_of_lord()
            if target_date <= baptism_of_lord:
                return LiturgicalSeason.CHRISTMAS, None
        
        # Check previous year's Christmas season
        if target_date.month == 1:
            baptism_of_lord = self._get_baptism_of_lord()
            if target_date <= baptism_of_lord:
                return LiturgicalSeason.CHRISTMAS, None
        
        # Advent (First Sunday of Advent - Dec 24)
        advent_start = self.advent_start
        if target_date >= advent_start and target_date < christmas:
            week = ((target_date - advent_start).days // 7) + 1
            return LiturgicalSeason.ADVENT, week
        
        # Lent (Ash Wednesday - Holy Saturday)
        ash_wednesday = easter - timedelta(days=46)
        holy_saturday = easter - timedelta(days=1)
        if ash_wednesday <= target_date <= holy_saturday:
            week = ((target_date - ash_wednesday).days // 7) + 1
            return LiturgicalSeason.LENT, week
        
        # Easter Triduum (Holy Thursday - Easter Sunday)
        holy_thursday = easter - timedelta(days=3)
        if holy_thursday <= target_date <= easter:
            return LiturgicalSeason.EASTER_TRIDUUM, None
        
        # Easter Season (Easter Sunday - Pentecost)
        pentecost = easter + timedelta(days=49)
        if easter < target_date <= pentecost:
            week = ((target_date - easter).days // 7) + 1
            return LiturgicalSeason.EASTER, week
        
        # Ordinary Time
        return LiturgicalSeason.ORDINARY_TIME, self._get_ordinary_time_week(target_date)
    
    def _get_baptism_of_lord(self) -> date:
        """Calculate the Feast of the Baptism of the Lord."""
        # First Sunday after January 6 (Epiphany)
        epiphany = date(self.year, 1, 6)
        days_to_sunday = (6 - epiphany.weekday()) % 7
        if days_to_sunday == 0:
            days_to_sunday = 7
        return epiphany + timedelta(days=days_to_sunday)
    
    def _get_ordinary_time_week(self, target_date: date) -> int:
        """Calculate the week number in Ordinary Time."""
        # This is a simplified calculation
        # In practice, this requires more complex logic
        baptism_of_lord = self._get_baptism_of_lord()
        ash_wednesday = self.easter_date - timedelta(days=46)
        pentecost = self.easter_date + timedelta(days=49)
        
        if target_date > baptism_of_lord and target_date < ash_wednesday:
            # First part of Ordinary Time
            days_since_baptism = (target_date - baptism_of_lord).days
            return (days_since_baptism // 7) + 1
        elif target_date > pentecost:
            # Second part of Ordinary Time
            days_since_pentecost = (target_date - pentecost).days
            # Add the weeks from the first part of Ordinary Time
            first_part_weeks = ((ash_wednesday - baptism_of_lord).days // 7)
            return first_part_weeks + (days_since_pentecost // 7) + 1
        
        return 1
    
    def get_liturgical_color(self, target_date: date, celebrations: List[Celebration]) -> LiturgicalColor:
        """Determine the liturgical color for a given date."""
        # Check if any celebration has a specific color
        for celebration in celebrations:
            if celebration.rank in [LiturgicalRank.SOLEMNITY, LiturgicalRank.FEAST]:
                return celebration.color
        
        season, _ = self.get_liturgical_season(target_date)
        
        # Default colors by season
        season_colors = {
            LiturgicalSeason.ADVENT: LiturgicalColor.PURPLE,
            LiturgicalSeason.CHRISTMAS: LiturgicalColor.WHITE,
            LiturgicalSeason.ORDINARY_TIME: LiturgicalColor.GREEN,
            LiturgicalSeason.LENT: LiturgicalColor.PURPLE,
            LiturgicalSeason.EASTER_TRIDUUM: LiturgicalColor.RED,  # Varies by day
            LiturgicalSeason.EASTER: LiturgicalColor.WHITE,
        }
        
        return season_colors.get(season, LiturgicalColor.GREEN)
    
    def get_fixed_celebrations(self, target_date: date) -> List[Celebration]:
        """Get fixed date celebrations (saints' days, etc.)."""
        celebrations = []
        month, day = target_date.month, target_date.day
        
        # Major fixed celebrations
        fixed_celebrations = {
            (1, 1): Celebration(
                name="Mary, Mother of God",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Solemnity of Mary, Mother of God"
            ),
            (1, 6): Celebration(
                name="Epiphany of the Lord",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Epiphany of the Lord"
            ),
            (3, 19): Celebration(
                name="Saint Joseph",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Saint Joseph, Spouse of the Blessed Virgin Mary"
            ),
            (3, 25): Celebration(
                name="Annunciation of the Lord",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Annunciation of the Lord"
            ),
            (8, 15): Celebration(
                name="Assumption of the Blessed Virgin Mary",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Assumption of the Blessed Virgin Mary"
            ),
            (11, 1): Celebration(
                name="All Saints",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="All Saints"
            ),
            (12, 8): Celebration(
                name="Immaculate Conception",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Immaculate Conception of the Blessed Virgin Mary"
            ),
            (12, 25): Celebration(
                name="Nativity of the Lord",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Christmas - Nativity of the Lord"
            ),
        }
        
        if (month, day) in fixed_celebrations:
            celebrations.append(fixed_celebrations[(month, day)])
        
        return celebrations
    
    def get_movable_celebrations(self, target_date: date) -> List[Celebration]:
        """Get movable celebrations based on Easter date."""
        celebrations = []
        easter = self.easter_date
        
        # Calculate movable feasts
        movable_feasts = {
            easter - timedelta(days=7): Celebration(
                name="Palm Sunday",
                rank=LiturgicalRank.SUNDAY,
                color=LiturgicalColor.RED,
                description="Palm Sunday of the Passion of the Lord"
            ),
            easter - timedelta(days=3): Celebration(
                name="Holy Thursday",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Holy Thursday - Mass of the Lord's Supper"
            ),
            easter - timedelta(days=2): Celebration(
                name="Good Friday",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.RED,
                description="Good Friday of the Passion of the Lord"
            ),
            easter - timedelta(days=1): Celebration(
                name="Holy Saturday",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Holy Saturday - Easter Vigil"
            ),
            easter: Celebration(
                name="Easter Sunday",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Easter Sunday - Resurrection of the Lord"
            ),
            easter + timedelta(days=39): Celebration(
                name="Ascension of the Lord",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Ascension of the Lord"
            ),
            easter + timedelta(days=49): Celebration(
                name="Pentecost",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.RED,
                description="Pentecost Sunday"
            ),
            easter + timedelta(days=56): Celebration(
                name="Trinity Sunday",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Most Holy Trinity"
            ),
            easter + timedelta(days=63): Celebration(
                name="Corpus Christi",
                rank=LiturgicalRank.SOLEMNITY,
                color=LiturgicalColor.WHITE,
                description="Most Holy Body and Blood of Christ"
            ),
        }
        
        if target_date in movable_feasts:
            celebrations.append(movable_feasts[target_date])
        
        return celebrations
    
    def get_liturgical_day(self, target_date: date) -> LiturgicalDay:
        """Get complete liturgical information for a specific date."""
        season, week = self.get_liturgical_season(target_date)
        
        # Get all celebrations for this date
        celebrations = []
        celebrations.extend(self.get_fixed_celebrations(target_date))
        celebrations.extend(self.get_movable_celebrations(target_date))
        
        # Determine primary celebration
        primary_celebration = None
        if celebrations:
            # Sort by rank priority (Solemnity > Feast > Memorial > etc.)
            rank_priority = {
                LiturgicalRank.SOLEMNITY: 1,
                LiturgicalRank.FEAST: 2,
                LiturgicalRank.MEMORIAL: 3,
                LiturgicalRank.OPTIONAL_MEMORIAL: 4,
                LiturgicalRank.SUNDAY: 5,
                LiturgicalRank.WEEKDAY: 6
            }
            celebrations.sort(key=lambda c: rank_priority.get(c.rank, 10))
            primary_celebration = celebrations[0]
        
        # Determine liturgical color
        color = self.get_liturgical_color(target_date, celebrations)
        
        return LiturgicalDay(
            date=target_date,
            season=season,
            season_week=week,
            weekday=target_date.strftime("%A"),
            celebrations=celebrations,
            primary_celebration=primary_celebration,
            color=color,
            source="Catholic Missal API - Liturgical Calendar Calculator"
        )