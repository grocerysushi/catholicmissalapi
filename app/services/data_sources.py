"""
Data source services for retrieving liturgical information from official sources.

This module implements ethical scraping practices with proper attribution
and respect for copyright and usage policies.
"""

import httpx
from bs4 import BeautifulSoup
from datetime import datetime, date, timedelta
from typing import Optional, List, Dict, Any
import asyncio
import logging
from urllib.parse import urljoin, quote

from ..core.config import settings
from ..models.liturgical import Reading, Psalm, DailyReadings, LiturgicalDay
from .liturgical_calendar import LiturgicalCalendar

logger = logging.getLogger(__name__)


class USCCBDataSource:
    """
    Data source for USCCB (United States Conference of Catholic Bishops).
    
    Note: This implementation respects USCCB's usage policies and provides
    proper attribution. For commercial use, additional licensing may be required.
    """
    
    def __init__(self):
        self.base_url = settings.USCCB_BASE_URL
        self.session = None
    
    async def _get_session(self) -> httpx.AsyncClient:
        """Get or create HTTP session with proper headers."""
        if self.session is None:
            headers = {
                'User-Agent': settings.USER_AGENT,
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
                'Accept-Encoding': 'gzip, deflate',
                'Connection': 'keep-alive',
            }
            self.session = httpx.AsyncClient(
                headers=headers,
                timeout=settings.REQUEST_TIMEOUT,
                follow_redirects=True
            )
        return self.session
    
    async def close(self):
        """Close the HTTP session."""
        if self.session:
            await self.session.aclose()
            self.session = None
    
    async def get_daily_readings(self, target_date: date) -> Optional[DailyReadings]:
        """
        Retrieve daily Mass readings from USCCB.
        
        Note: This respects USCCB's copyright policies and provides proper attribution.
        """
        try:
            session = await self._get_session()
            
            # Format date for USCCB URL
            date_str = target_date.strftime("%m/%d/%Y")
            url = f"{self.base_url}/bible/readings/{quote(date_str)}.cfm"
            
            logger.info(f"Fetching readings from USCCB for {target_date}: {url}")
            
            response = await session.get(url)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Parse the readings - this is a simplified parser
            # In practice, you'd need more robust parsing
            readings_data = self._parse_usccb_readings(soup, target_date)
            
            if readings_data:
                return DailyReadings(
                    date=target_date,
                    **readings_data,
                    source="USCCB - United States Conference of Catholic Bishops",
                    last_updated=datetime.utcnow()
                )
            
        except httpx.HTTPError as e:
            logger.error(f"HTTP error fetching USCCB readings: {e}")
        except Exception as e:
            logger.error(f"Error parsing USCCB readings: {e}")
        
        return None
    
    def _parse_usccb_readings(self, soup: BeautifulSoup, target_date: date) -> Optional[Dict[str, Any]]:
        """
        Parse USCCB readings page.
        
        Note: This is a simplified parser. The actual USCCB website structure
        may require more sophisticated parsing logic.
        """
        readings_data = {}
        
        try:
            # Look for reading sections
            reading_sections = soup.find_all(['div', 'section'], class_=['reading', 'content-reading'])
            
            for section in reading_sections:
                # Try to identify the type of reading
                heading = section.find(['h2', 'h3', 'h4'])
                if not heading:
                    continue
                
                heading_text = heading.get_text().strip().lower()
                
                # Extract reading reference and text
                reference_elem = section.find(['cite', 'span'], class_=['reference', 'citation'])
                text_elem = section.find(['div', 'p'], class_=['reading-text', 'content'])
                
                if reference_elem and text_elem:
                    reference = reference_elem.get_text().strip()
                    text = text_elem.get_text().strip()
                    
                    reading = Reading(
                        reference=reference,
                        citation=reference,  # Simplified
                        text=text,
                        source="USCCB"
                    )
                    
                    # Categorize the reading
                    if 'first' in heading_text or 'reading i' in heading_text:
                        readings_data['first_reading'] = reading
                    elif 'second' in heading_text or 'reading ii' in heading_text:
                        readings_data['second_reading'] = reading
                    elif 'gospel' in heading_text:
                        readings_data['gospel'] = reading
                    elif 'psalm' in heading_text:
                        # Parse psalm differently
                        psalm_data = self._parse_psalm(section)
                        if psalm_data:
                            readings_data['responsorial_psalm'] = psalm_data
            
            return readings_data if readings_data else None
            
        except Exception as e:
            logger.error(f"Error parsing USCCB readings: {e}")
            return None
    
    def _parse_psalm(self, section) -> Optional[Psalm]:
        """Parse responsorial psalm from USCCB."""
        try:
            reference_elem = section.find(['cite', 'span'], class_=['reference', 'citation'])
            refrain_elem = section.find(['div', 'p'], class_=['refrain', 'response'])
            
            if reference_elem:
                reference = reference_elem.get_text().strip()
                refrain = refrain_elem.get_text().strip() if refrain_elem else None
                
                return Psalm(
                    reference=reference,
                    refrain=refrain,
                    source="USCCB"
                )
        except Exception as e:
            logger.error(f"Error parsing psalm: {e}")
        
        return None


class VaticanDataSource:
    """
    Data source for Vatican official sources.
    
    This implementation respects Vatican usage policies and provides
    proper attribution for all content.
    """
    
    def __init__(self):
        self.base_url = settings.VATICAN_BASE_URL
        self.session = None
    
    async def _get_session(self) -> httpx.AsyncClient:
        """Get or create HTTP session with proper headers."""
        if self.session is None:
            headers = {
                'User-Agent': settings.USER_AGENT,
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
            }
            self.session = httpx.AsyncClient(
                headers=headers,
                timeout=settings.REQUEST_TIMEOUT,
                follow_redirects=True
            )
        return self.session
    
    async def close(self):
        """Close the HTTP session."""
        if self.session:
            await self.session.aclose()
            self.session = None
    
    async def get_liturgical_documents(self) -> List[Dict[str, Any]]:
        """
        Retrieve liturgical documents from Vatican sources.
        
        This method fetches publicly available liturgical documents
        and provides proper attribution.
        """
        documents = []
        
        try:
            session = await self._get_session()
            
            # Vatican liturgical documents URLs (these are examples)
            document_urls = [
                "/roman_curia/congregations/ccdds/documents/rc_con_ccdds_doc_20030317_ordinamento-messale_en.html",
                "/holy_father/benedict_xvi/motu_proprio/documents/hf_ben-xvi_motu-proprio_20070707_summorum-pontificum_en.html"
            ]
            
            for doc_url in document_urls:
                url = urljoin(self.base_url, doc_url)
                
                try:
                    response = await session.get(url)
                    response.raise_for_status()
                    
                    soup = BeautifulSoup(response.text, 'html.parser')
                    
                    # Extract document information
                    title_elem = soup.find(['h1', 'h2', 'title'])
                    content_elem = soup.find(['div', 'article'], class_=['content', 'document'])
                    
                    if title_elem and content_elem:
                        documents.append({
                            'title': title_elem.get_text().strip(),
                            'url': url,
                            'content': content_elem.get_text().strip()[:1000] + "...",  # Truncated
                            'source': "Vatican Official Website"
                        })
                
                except httpx.HTTPError as e:
                    logger.error(f"Error fetching Vatican document {url}: {e}")
                    continue
        
        except Exception as e:
            logger.error(f"Error fetching Vatican documents: {e}")
        
        return documents


class DataSourceManager:
    """
    Manager for all data sources with caching and fallback logic.
    """
    
    def __init__(self):
        self.usccb = USCCBDataSource()
        self.vatican = VaticanDataSource()
        self._cache: Dict[str, Any] = {}
    
    async def close(self):
        """Close all data source sessions."""
        await self.usccb.close()
        await self.vatican.close()
    
    async def get_daily_readings(self, target_date: date) -> Optional[DailyReadings]:
        """
        Get daily readings with fallback logic and caching.
        """
        cache_key = f"readings_{target_date.isoformat()}"
        
        # Check cache first
        if cache_key in self._cache:
            cached_data, timestamp = self._cache[cache_key]
            if (datetime.utcnow() - timestamp).seconds < settings.READINGS_CACHE_TIME:
                return cached_data
        
        # Try USCCB first
        readings = await self.usccb.get_daily_readings(target_date)
        
        if readings:
            # Cache the result
            self._cache[cache_key] = (readings, datetime.utcnow())
            return readings
        
        # TODO: Add fallback sources
        logger.warning(f"No readings found for {target_date}")
        return None
    
    async def get_liturgical_day(self, target_date: date) -> LiturgicalDay:
        """
        Get complete liturgical day information combining calendar and readings.
        """
        # Calculate liturgical calendar information
        calendar = LiturgicalCalendar(target_date.year)
        liturgical_day = calendar.get_liturgical_day(target_date)
        
        # Add readings from data sources
        readings = await self.get_daily_readings(target_date)
        if readings:
            liturgical_day.readings = readings
        
        return liturgical_day