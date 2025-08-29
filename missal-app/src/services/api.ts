import axios from 'axios';

const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? 'https://your-api-domain.com' 
  : 'http://localhost:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    console.log(`Making API request to: ${config.url}`);
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error('API Error:', error);
    if (error.response?.status === 404) {
      throw new Error('Resource not found');
    } else if (error.response?.status >= 500) {
      throw new Error('Server error. Please try again later.');
    } else if (error.code === 'ECONNABORTED') {
      throw new Error('Request timeout. Please check your connection.');
    }
    throw error;
  }
);

export interface Reading {
  reference: string;
  citation: string;
  text?: string;
  short_text?: string;
  source: string;
}

export interface Psalm {
  reference: string;
  refrain?: string;
  verses?: string[];
  source: string;
}

export interface DailyReadings {
  date: string;
  first_reading?: Reading;
  responsorial_psalm?: Psalm;
  second_reading?: Reading;
  gospel_acclamation?: string;
  gospel?: Reading;
  source: string;
  last_updated: string;
}

export interface Celebration {
  name: string;
  rank: string;
  color: string;
  description?: string;
  proper_readings: boolean;
}

export interface LiturgicalDay {
  date: string;
  season: string;
  season_week?: number;
  weekday: string;
  celebrations: Celebration[];
  primary_celebration?: Celebration;
  color: string;
  readings?: DailyReadings;
  source: string;
  last_updated: string;
}

export interface Prayer {
  name: string;
  category: string;
  text: string;
  source: string;
  language: string;
  copyright_notice?: string;
}

export interface APIResponse<T> {
  success: boolean;
  source_attribution: string;
  data?: T;
}

export interface ReadingsResponse extends APIResponse<DailyReadings> {
  readings: DailyReadings;
}

export interface CalendarResponse extends APIResponse<LiturgicalDay> {
  liturgical_day: LiturgicalDay;
}

export interface PrayersResponse extends APIResponse<Prayer[]> {
  prayers: Prayer[];
}

// API Service Class
class MissalAPIService {
  // Calendar endpoints
  async getTodayCalendar(): Promise<CalendarResponse> {
    const response = await api.get<CalendarResponse>('/api/v1/calendar/today');
    return response.data;
  }

  async getCalendarForDate(date: string): Promise<CalendarResponse> {
    const response = await api.get<CalendarResponse>(`/api/v1/calendar/${date}`);
    return response.data;
  }

  // Readings endpoints
  async getTodayReadings(): Promise<ReadingsResponse> {
    const response = await api.get<ReadingsResponse>('/api/v1/readings/today');
    return response.data;
  }

  async getReadingsForDate(date: string): Promise<ReadingsResponse> {
    const response = await api.get<ReadingsResponse>(`/api/v1/readings/${date}`);
    return response.data;
  }

  async getReadingsRange(startDate: string, endDate: string): Promise<any> {
    const response = await api.get(`/api/v1/readings/range/${startDate}/${endDate}`);
    return response.data;
  }

  // Prayers endpoints
  async getCommonPrayers(): Promise<PrayersResponse> {
    const response = await api.get<PrayersResponse>('/api/v1/prayers/common');
    return response.data;
  }

  async getPrayersByCategory(category: string): Promise<PrayersResponse> {
    const response = await api.get<PrayersResponse>(`/api/v1/prayers/category/${category}`);
    return response.data;
  }

  async getSeasonalPrayers(season: string): Promise<PrayersResponse> {
    const response = await api.get<PrayersResponse>(`/api/v1/prayers/seasonal/${season}`);
    return response.data;
  }

  // Utility methods
  formatDate(date: Date): string {
    return date.toISOString().split('T')[0];
  }

  async healthCheck(): Promise<boolean> {
    try {
      const response = await api.get('/api/v1/info');
      return response.status === 200;
    } catch {
      return false;
    }
  }
}

export const missalAPI = new MissalAPIService();
export default missalAPI;