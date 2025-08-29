import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import { Calendar, Book, ChevronLeft, ChevronRight, Printer } from 'lucide-react';
import { Reading, DailyReadings as DailyReadingsType, Psalm } from '../../services/api';
import missalAPI from '../../services/api';
import LoadingSpinner from '../UI/LoadingSpinner';
import ErrorMessage from '../UI/ErrorMessage';

interface ReadingCardProps {
  title: string;
  reading?: Reading;
  psalm?: Psalm;
  acclamation?: string;
  className?: string;
}

const ReadingCard: React.FC<ReadingCardProps> = ({ 
  title, 
  reading, 
  psalm, 
  acclamation, 
  className = '' 
}) => {
  if (!reading && !psalm && !acclamation) {
    return null;
  }

  return (
    <div className={`card ${className}`}>
      <h3 className="text-xl font-bold text-catholic-red mb-4 font-serif">{title}</h3>
      
      {reading && (
        <div>
          <div className="mb-3">
            <p className="text-sm font-medium text-gray-600 mb-1">Reading:</p>
            <p className="font-semibold text-gray-900">{reading.reference}</p>
            <p className="text-sm text-gray-500">{reading.citation}</p>
          </div>
          {reading.text && (
            <div className="scripture-text mb-4">
              {reading.text.split('\n').map((paragraph, index) => (
                <p key={index} className="mb-3">
                  {paragraph}
                </p>
              ))}
            </div>
          )}
          <p className="text-xs text-gray-500">Source: {reading.source}</p>
        </div>
      )}

      {psalm && (
        <div>
          <div className="mb-3">
            <p className="text-sm font-medium text-gray-600 mb-1">Responsorial Psalm:</p>
            <p className="font-semibold text-gray-900">{psalm.reference}</p>
          </div>
          {psalm.refrain && (
            <div className="bg-gray-50 p-3 rounded-lg mb-4">
              <p className="text-sm font-medium text-gray-600 mb-1">Refrain:</p>
              <p className="scripture-text font-semibold">{psalm.refrain}</p>
            </div>
          )}
          {psalm.verses && (
            <div className="scripture-text">
              {psalm.verses.map((verse, index) => (
                <p key={index} className="mb-2">
                  {verse}
                </p>
              ))}
            </div>
          )}
          <p className="text-xs text-gray-500">Source: {psalm.source}</p>
        </div>
      )}

      {acclamation && (
        <div>
          <p className="text-sm font-medium text-gray-600 mb-2">Gospel Acclamation:</p>
          <div className="bg-yellow-50 p-3 rounded-lg">
            <p className="scripture-text font-semibold text-yellow-800">{acclamation}</p>
          </div>
        </div>
      )}
    </div>
  );
};

const DailyReadings: React.FC = () => {
  const [readings, setReadings] = useState<DailyReadingsType | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());

  const fetchReadings = async (date: Date) => {
    setLoading(true);
    setError(null);
    
    try {
      const dateString = missalAPI.formatDate(date);
      const response = await missalAPI.getReadingsForDate(dateString);
      setReadings(response.readings);
    } catch (err) {
      console.error('Error fetching readings:', err);
      setError(err instanceof Error ? err.message : 'Failed to load readings');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReadings(selectedDate);
  }, [selectedDate]);

  const handleDateChange = (days: number) => {
    const newDate = new Date(selectedDate);
    newDate.setDate(newDate.getDate() + days);
    setSelectedDate(newDate);
  };

  const handlePrint = () => {
    window.print();
  };

  const isToday = (date: Date) => {
    const today = new Date();
    return date.toDateString() === today.toDateString();
  };

  if (loading) {
    return <LoadingSpinner size="lg" text="Loading daily readings..." />;
  }

  if (error) {
    return (
      <ErrorMessage 
        message={error} 
        onRetry={() => fetchReadings(selectedDate)}
      />
    );
  }

  return (
    <div className="max-w-4xl mx-auto p-6">
      {/* Date Navigation */}
      <div className="flex items-center justify-between mb-8 bg-white rounded-lg shadow-md p-4">
        <button
          onClick={() => handleDateChange(-1)}
          className="flex items-center space-x-2 text-gray-600 hover:text-catholic-red transition-colors"
        >
          <ChevronLeft className="h-5 w-5" />
          <span>Previous Day</span>
        </button>

        <div className="flex items-center space-x-4">
          <Calendar className="h-5 w-5 text-catholic-red" />
          <div className="text-center">
            <h1 className="text-2xl font-bold text-gray-900 font-serif">
              {format(selectedDate, 'EEEE, MMMM d, yyyy')}
            </h1>
            {isToday(selectedDate) && (
              <span className="inline-block bg-catholic-red text-white text-xs px-2 py-1 rounded-full mt-1">
                Today
              </span>
            )}
          </div>
          <button
            onClick={handlePrint}
            className="flex items-center space-x-2 text-gray-600 hover:text-catholic-red transition-colors no-print"
          >
            <Printer className="h-4 w-4" />
            <span>Print</span>
          </button>
        </div>

        <button
          onClick={() => handleDateChange(1)}
          className="flex items-center space-x-2 text-gray-600 hover:text-catholic-red transition-colors"
        >
          <span>Next Day</span>
          <ChevronRight className="h-5 w-5" />
        </button>
      </div>

      {/* Quick Navigation */}
      <div className="flex flex-wrap gap-2 mb-6 justify-center">
        <button
          onClick={() => setSelectedDate(new Date())}
          className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
            isToday(selectedDate)
              ? 'bg-catholic-red text-white'
              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
          }`}
        >
          Today
        </button>
        <button
          onClick={() => {
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            setSelectedDate(tomorrow);
          }}
          className="px-4 py-2 rounded-lg text-sm font-medium bg-gray-200 text-gray-700 hover:bg-gray-300 transition-colors"
        >
          Tomorrow
        </button>
        <button
          onClick={() => {
            const nextSunday = new Date();
            const daysUntilSunday = (7 - nextSunday.getDay()) % 7 || 7;
            nextSunday.setDate(nextSunday.getDate() + daysUntilSunday);
            setSelectedDate(nextSunday);
          }}
          className="px-4 py-2 rounded-lg text-sm font-medium bg-gray-200 text-gray-700 hover:bg-gray-300 transition-colors"
        >
          Next Sunday
        </button>
      </div>

      {readings ? (
        <div className="space-y-6">
          {/* First Reading */}
          <ReadingCard
            title="First Reading"
            reading={readings.first_reading}
            className="animate-fade-in"
          />

          {/* Responsorial Psalm */}
          <ReadingCard
            title="Responsorial Psalm"
            psalm={readings.responsorial_psalm}
            className="animate-fade-in"
          />

          {/* Second Reading (Sundays and Solemnities) */}
          {readings.second_reading && (
            <ReadingCard
              title="Second Reading"
              reading={readings.second_reading}
              className="animate-fade-in"
            />
          )}

          {/* Gospel Acclamation */}
          {readings.gospel_acclamation && (
            <ReadingCard
              title="Gospel Acclamation"
              acclamation={readings.gospel_acclamation}
              className="animate-fade-in"
            />
          )}

          {/* Gospel */}
          <ReadingCard
            title="Gospel"
            reading={readings.gospel}
            className="animate-fade-in border-l-4 border-catholic-gold"
          />

          {/* Source Attribution */}
          <div className="bg-gray-50 rounded-lg p-4 text-sm text-gray-600">
            <div className="flex items-start space-x-2">
              <Book className="h-4 w-4 mt-0.5 text-gray-500" />
              <div>
                <p className="font-medium mb-1">Source Information:</p>
                <p>{readings.source}</p>
                <p className="text-xs mt-2">
                  Last updated: {format(new Date(readings.last_updated), 'PPpp')}
                </p>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className="text-center py-12">
          <Book className="h-16 w-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-gray-600 mb-2">No Readings Available</h3>
          <p className="text-gray-500">
            Readings for {format(selectedDate, 'MMMM d, yyyy')} are not available at this time.
          </p>
        </div>
      )}
    </div>
  );
};

export default DailyReadings;