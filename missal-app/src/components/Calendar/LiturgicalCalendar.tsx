import React, { useState, useEffect } from 'react';
import { format, startOfMonth, endOfMonth, eachDayOfInterval, isSameMonth, isSameDay, isToday } from 'date-fns';
import { Calendar as CalendarIcon, ChevronLeft, ChevronRight, Crown, Star } from 'lucide-react';
import { LiturgicalDay, Celebration } from '../../services/api';
import missalAPI from '../../services/api';
import LoadingSpinner from '../UI/LoadingSpinner';
import ErrorMessage from '../UI/ErrorMessage';

interface CalendarDayProps {
  date: Date;
  currentMonth: Date;
  liturgicalDay?: LiturgicalDay;
  onClick: (date: Date) => void;
  isSelected: boolean;
}

const CalendarDay: React.FC<CalendarDayProps> = ({ 
  date, 
  currentMonth, 
  liturgicalDay, 
  onClick, 
  isSelected 
}) => {
  const isCurrentMonth = isSameMonth(date, currentMonth);
  const isTodayDate = isToday(date);
  
  const getColorClass = (color: string) => {
    const colorMap: Record<string, string> = {
      'White': 'bg-white border-gray-300',
      'Red': 'bg-red-100 border-red-300',
      'Green': 'bg-green-100 border-green-300',
      'Purple': 'bg-purple-100 border-purple-300',
      'Rose': 'bg-pink-100 border-pink-300',
      'Black': 'bg-gray-200 border-gray-400'
    };
    return colorMap[color] || 'bg-gray-50 border-gray-200';
  };

  const getRankIcon = (rank: string) => {
    if (rank === 'Solemnity') return <Crown className="h-3 w-3" />;
    if (rank === 'Feast') return <Star className="h-3 w-3" />;
    return null;
  };

  return (
    <button
      onClick={() => onClick(date)}
      className={`
        w-full h-20 p-1 border rounded-lg transition-all duration-200 hover:shadow-md
        ${isCurrentMonth ? 'opacity-100' : 'opacity-30'}
        ${isTodayDate ? 'ring-2 ring-catholic-red' : ''}
        ${isSelected ? 'ring-2 ring-catholic-gold' : ''}
        ${liturgicalDay ? getColorClass(liturgicalDay.color) : 'bg-gray-50 border-gray-200'}
      `}
    >
      <div className="h-full flex flex-col justify-between">
        <div className="flex justify-between items-start">
          <span className={`text-sm font-medium ${
            isTodayDate ? 'text-catholic-red font-bold' : 'text-gray-900'
          }`}>
            {format(date, 'd')}
          </span>
          {liturgicalDay?.primary_celebration && getRankIcon(liturgicalDay.primary_celebration.rank)}
        </div>
        
        {liturgicalDay?.primary_celebration && (
          <div className="text-xs text-gray-700 line-clamp-2">
            {liturgicalDay.primary_celebration.name}
          </div>
        )}
        
        <div className="text-xs text-gray-500">
          {liturgicalDay?.season}
        </div>
      </div>
    </button>
  );
};

interface DayDetailsProps {
  liturgicalDay: LiturgicalDay;
  onClose: () => void;
}

const DayDetails: React.FC<DayDetailsProps> = ({ liturgicalDay, onClose }) => {
  const getColorClass = (color: string) => {
    const colorMap: Record<string, string> = {
      'White': 'liturgical-color-white',
      'Red': 'liturgical-color-red',
      'Green': 'liturgical-color-green',
      'Purple': 'liturgical-color-purple',
      'Rose': 'liturgical-color-rose',
      'Black': 'liturgical-color-black'
    };
    return colorMap[color] || 'border-l-4 border-gray-300 bg-gray-50';
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b p-4 flex justify-between items-center">
          <h2 className="text-xl font-bold font-serif text-catholic-red">
            {format(new Date(liturgicalDay.date), 'EEEE, MMMM d, yyyy')}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            <span className="text-2xl">&times;</span>
          </button>
        </div>
        
        <div className="p-6 space-y-6">
          {/* Basic Information */}
          <div className={`p-4 rounded-lg ${getColorClass(liturgicalDay.color)}`}>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-gray-600">Season</p>
                <p className="font-semibold">{liturgicalDay.season}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-600">Liturgical Color</p>
                <p className="font-semibold">{liturgicalDay.color}</p>
              </div>
              {liturgicalDay.season_week && (
                <div>
                  <p className="text-sm font-medium text-gray-600">Week</p>
                  <p className="font-semibold">Week {liturgicalDay.season_week}</p>
                </div>
              )}
            </div>
          </div>

          {/* Celebrations */}
          {liturgicalDay.celebrations.length > 0 && (
            <div>
              <h3 className="text-lg font-semibold mb-3 font-serif">Celebrations</h3>
              <div className="space-y-3">
                {liturgicalDay.celebrations.map((celebration, index) => (
                  <div key={index} className="bg-gray-50 p-4 rounded-lg">
                    <div className="flex items-start justify-between">
                      <div>
                        <h4 className="font-semibold text-gray-900">{celebration.name}</h4>
                        <p className="text-sm text-gray-600">{celebration.rank}</p>
                        {celebration.description && (
                          <p className="text-sm text-gray-700 mt-2">{celebration.description}</p>
                        )}
                      </div>
                      <div className="flex items-center space-x-1 text-gray-500">
                        {celebration.rank === 'Solemnity' && <Crown className="h-4 w-4" />}
                        {celebration.rank === 'Feast' && <Star className="h-4 w-4" />}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Source Information */}
          <div className="bg-gray-50 p-4 rounded-lg text-sm text-gray-600">
            <p className="font-medium mb-1">Source:</p>
            <p>{liturgicalDay.source}</p>
            <p className="text-xs mt-2">
              Last updated: {format(new Date(liturgicalDay.last_updated), 'PPpp')}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

const LiturgicalCalendar: React.FC = () => {
  const [currentMonth, setCurrentMonth] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [liturgicalDays, setLiturgicalDays] = useState<Record<string, LiturgicalDay>>({});
  const [selectedDayDetails, setSelectedDayDetails] = useState<LiturgicalDay | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const monthStart = startOfMonth(currentMonth);
  const monthEnd = endOfMonth(currentMonth);
  const calendarDays = eachDayOfInterval({ start: monthStart, end: monthEnd });

  const fetchMonthData = async (month: Date) => {
    setLoading(true);
    setError(null);
    
    try {
      // For demo purposes, we'll fetch a few key dates
      // In a real implementation, you might have a bulk endpoint
      const promises = calendarDays.slice(0, 10).map(async (date) => {
        try {
          const dateString = missalAPI.formatDate(date);
          const response = await missalAPI.getCalendarForDate(dateString);
          return { date: dateString, data: response.liturgical_day };
        } catch {
          return null;
        }
      });

      const results = await Promise.all(promises);
      const newLiturgicalDays: Record<string, LiturgicalDay> = {};
      
      results.forEach((result) => {
        if (result) {
          newLiturgicalDays[result.date] = result.data;
        }
      });

      setLiturgicalDays(newLiturgicalDays);
    } catch (err) {
      console.error('Error fetching calendar data:', err);
      setError('Failed to load calendar data');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMonthData(currentMonth);
  }, [currentMonth]);

  const handleDateClick = async (date: Date) => {
    setSelectedDate(date);
    const dateString = missalAPI.formatDate(date);
    
    if (liturgicalDays[dateString]) {
      setSelectedDayDetails(liturgicalDays[dateString]);
    } else {
      // Fetch data for this specific date
      try {
        const response = await missalAPI.getCalendarForDate(dateString);
        setSelectedDayDetails(response.liturgical_day);
      } catch (err) {
        console.error('Error fetching day details:', err);
      }
    }
  };

  const navigateMonth = (direction: 'prev' | 'next') => {
    const newMonth = new Date(currentMonth);
    if (direction === 'prev') {
      newMonth.setMonth(newMonth.getMonth() - 1);
    } else {
      newMonth.setMonth(newMonth.getMonth() + 1);
    }
    setCurrentMonth(newMonth);
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center space-x-3">
          <CalendarIcon className="h-8 w-8 text-catholic-red" />
          <h1 className="text-3xl font-bold font-serif text-gray-900">Liturgical Calendar</h1>
        </div>
        
        <div className="flex items-center space-x-4">
          <button
            onClick={() => navigateMonth('prev')}
            className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <ChevronLeft className="h-5 w-5" />
          </button>
          
          <h2 className="text-xl font-semibold min-w-[200px] text-center">
            {format(currentMonth, 'MMMM yyyy')}
          </h2>
          
          <button
            onClick={() => navigateMonth('next')}
            className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <ChevronRight className="h-5 w-5" />
          </button>
        </div>

        <button
          onClick={() => setCurrentMonth(new Date())}
          className="btn-primary"
        >
          Today
        </button>
      </div>

      {/* Legend */}
      <div className="bg-white rounded-lg shadow-md p-4 mb-6">
        <h3 className="font-semibold mb-3">Liturgical Colors</h3>
        <div className="flex flex-wrap gap-4 text-sm">
          <div className="flex items-center space-x-2">
            <div className="w-4 h-4 bg-white border border-gray-300 rounded"></div>
            <span>White/Gold</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-4 h-4 bg-red-100 border border-red-300 rounded"></div>
            <span>Red</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-4 h-4 bg-green-100 border border-green-300 rounded"></div>
            <span>Green</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-4 h-4 bg-purple-100 border border-purple-300 rounded"></div>
            <span>Purple</span>
          </div>
          <div className="flex items-center space-x-2">
            <div className="w-4 h-4 bg-pink-100 border border-pink-300 rounded"></div>
            <span>Rose</span>
          </div>
        </div>
        <div className="flex items-center space-x-4 mt-2 text-sm">
          <div className="flex items-center space-x-1">
            <Crown className="h-4 w-4" />
            <span>Solemnity</span>
          </div>
          <div className="flex items-center space-x-1">
            <Star className="h-4 w-4" />
            <span>Feast</span>
          </div>
        </div>
      </div>

      {/* Calendar Grid */}
      {loading ? (
        <LoadingSpinner size="lg" text="Loading calendar..." />
      ) : error ? (
        <ErrorMessage message={error} onRetry={() => fetchMonthData(currentMonth)} />
      ) : (
        <div className="bg-white rounded-lg shadow-md p-6">
          {/* Weekday Headers */}
          <div className="grid grid-cols-7 gap-2 mb-4">
            {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
              <div key={day} className="text-center font-semibold text-gray-600 py-2">
                {day}
              </div>
            ))}
          </div>

          {/* Calendar Days */}
          <div className="grid grid-cols-7 gap-2">
            {calendarDays.map((date) => {
              const dateString = missalAPI.formatDate(date);
              return (
                <CalendarDay
                  key={dateString}
                  date={date}
                  currentMonth={currentMonth}
                  liturgicalDay={liturgicalDays[dateString]}
                  onClick={handleDateClick}
                  isSelected={selectedDate ? isSameDay(date, selectedDate) : false}
                />
              );
            })}
          </div>
        </div>
      )}

      {/* Day Details Modal */}
      {selectedDayDetails && (
        <DayDetails
          liturgicalDay={selectedDayDetails}
          onClose={() => setSelectedDayDetails(null)}
        />
      )}
    </div>
  );
};

export default LiturgicalCalendar;