import React, { useState, useEffect } from 'react';
import { Heart, Search, Filter, BookOpen, Star, Users, Cross } from 'lucide-react';
import { Prayer } from '../../services/api';
import missalAPI from '../../services/api';
import LoadingSpinner from '../UI/LoadingSpinner';
import ErrorMessage from '../UI/ErrorMessage';

interface PrayerCardProps {
  prayer: Prayer;
  isExpanded: boolean;
  onToggle: () => void;
}

const PrayerCard: React.FC<PrayerCardProps> = ({ prayer, isExpanded, onToggle }) => {
  const getCategoryIcon = (category: string) => {
    const iconMap: Record<string, React.ReactNode> = {
      'marian': <Star className="h-5 w-5 text-blue-600" />,
      'penitential': <Cross className="h-5 w-5 text-purple-600" />,
      'eucharistic': <Heart className="h-5 w-5 text-red-600" />,
      'common': <BookOpen className="h-5 w-5 text-green-600" />,
      'seasonal': <Users className="h-5 w-5 text-orange-600" />,
    };
    return iconMap[category.toLowerCase()] || <BookOpen className="h-5 w-5 text-gray-600" />;
  };

  return (
    <div className="card-hover animate-fade-in">
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center space-x-3">
          {getCategoryIcon(prayer.category)}
          <div>
            <h3 className="text-lg font-semibold font-serif text-gray-900">{prayer.name}</h3>
            <p className="text-sm text-gray-600 capitalize">{prayer.category.replace('_', ' ')}</p>
          </div>
        </div>
        <button
          onClick={onToggle}
          className="text-catholic-red hover:text-red-700 font-medium text-sm"
        >
          {isExpanded ? 'Collapse' : 'Expand'}
        </button>
      </div>

      {isExpanded ? (
        <div className="space-y-4">
          <div className="prayer-text text-gray-800 leading-relaxed">
            {prayer.text.split('\n').map((paragraph, index) => (
              <p key={index} className="mb-3">
                {paragraph}
              </p>
            ))}
          </div>
          
          <div className="text-xs text-gray-500 border-t pt-3">
            <p>Source: {prayer.source}</p>
            {prayer.copyright_notice && (
              <p className="mt-1">© {prayer.copyright_notice}</p>
            )}
          </div>
        </div>
      ) : (
        <div className="text-gray-600">
          <p className="line-clamp-2">{prayer.text}</p>
          <p className="text-sm text-catholic-red mt-2 cursor-pointer" onClick={onToggle}>
            Click to read full prayer...
          </p>
        </div>
      )}
    </div>
  );
};

interface CategoryTabProps {
  category: string;
  label: string;
  icon: React.ReactNode;
  isActive: boolean;
  onClick: () => void;
  count?: number;
}

const CategoryTab: React.FC<CategoryTabProps> = ({ 
  category, 
  label, 
  icon, 
  isActive, 
  onClick, 
  count 
}) => {
  return (
    <button
      onClick={onClick}
      className={`flex items-center space-x-2 px-4 py-3 rounded-lg font-medium transition-colors duration-200 ${
        isActive
          ? 'bg-catholic-red text-white shadow-md'
          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      }`}
    >
      {icon}
      <span>{label}</span>
      {count !== undefined && (
        <span className={`text-xs px-2 py-1 rounded-full ${
          isActive ? 'bg-white/20' : 'bg-gray-300'
        }`}>
          {count}
        </span>
      )}
    </button>
  );
};

const PrayersSection: React.FC = () => {
  const [prayers, setPrayers] = useState<Prayer[]>([]);
  const [filteredPrayers, setFilteredPrayers] = useState<Prayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('common');
  const [searchTerm, setSearchTerm] = useState('');
  const [expandedPrayers, setExpandedPrayers] = useState<Set<string>>(new Set());

  const categories = [
    { key: 'common', label: 'Common Prayers', icon: <BookOpen className="h-4 w-4" /> },
    { key: 'marian', label: 'Marian Prayers', icon: <Star className="h-4 w-4" /> },
    { key: 'penitential', label: 'Penitential', icon: <Cross className="h-4 w-4" /> },
    { key: 'eucharistic', label: 'Eucharistic', icon: <Heart className="h-4 w-4" /> },
  ];

  const seasons = [
    { key: 'advent', label: 'Advent' },
    { key: 'christmas', label: 'Christmas' },
    { key: 'lent', label: 'Lent' },
    { key: 'easter', label: 'Easter' },
  ];

  const fetchPrayers = async (category: string) => {
    setLoading(true);
    setError(null);
    
    try {
      let response;
      if (category === 'common') {
        response = await missalAPI.getCommonPrayers();
      } else if (seasons.some(s => s.key === category)) {
        response = await missalAPI.getSeasonalPrayers(category);
      } else {
        response = await missalAPI.getPrayersByCategory(category);
      }
      
      setPrayers(response.prayers);
      setFilteredPrayers(response.prayers);
    } catch (err) {
      console.error('Error fetching prayers:', err);
      setError(err instanceof Error ? err.message : 'Failed to load prayers');
      // Set some sample prayers for demo
      const samplePrayers: Prayer[] = [
        {
          name: "Our Father",
          category: "common",
          text: "Our Father, who art in heaven,\nhallowed be thy name.\nThy kingdom come,\nthy will be done,\non earth as it is in heaven.\n\nGive us this day our daily bread,\nand forgive us our trespasses,\nas we forgive those who trespass against us.\n\nAnd lead us not into temptation,\nbut deliver us from evil.\n\nAmen.",
          source: "Traditional Catholic Prayer",
          language: "en"
        },
        {
          name: "Hail Mary",
          category: "marian",
          text: "Hail Mary, full of grace,\nthe Lord is with thee.\nBlessed art thou amongst women,\nand blessed is the fruit of thy womb, Jesus.\n\nHoly Mary, Mother of God,\npray for us sinners,\nnow and at the hour of our death.\n\nAmen.",
          source: "Traditional Catholic Prayer",
          language: "en"
        },
        {
          name: "Glory Be",
          category: "common",
          text: "Glory be to the Father,\nand to the Son,\nand to the Holy Spirit.\n\nAs it was in the beginning,\nis now, and ever shall be,\nworld without end.\n\nAmen.",
          source: "Traditional Catholic Prayer",
          language: "en"
        },
        {
          name: "Act of Contrition",
          category: "penitential",
          text: "O my God, I am heartily sorry for having offended Thee,\nand I detest all my sins because of thy just punishments,\nbut most of all because they offend Thee, my God,\nwho art all good and deserving of all my love.\n\nI firmly resolve with the help of Thy grace\nto sin no more and to avoid the near occasion of sin.\n\nAmen.",
          source: "Traditional Catholic Prayer",
          language: "en"
        }
      ];
      
      const categoryPrayers = samplePrayers.filter(p => p.category === category);
      setPrayers(categoryPrayers);
      setFilteredPrayers(categoryPrayers);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPrayers(selectedCategory);
  }, [selectedCategory]);

  useEffect(() => {
    if (searchTerm.trim() === '') {
      setFilteredPrayers(prayers);
    } else {
      const filtered = prayers.filter(prayer =>
        prayer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        prayer.text.toLowerCase().includes(searchTerm.toLowerCase())
      );
      setFilteredPrayers(filtered);
    }
  }, [searchTerm, prayers]);

  const togglePrayerExpansion = (prayerName: string) => {
    const newExpanded = new Set(expandedPrayers);
    if (newExpanded.has(prayerName)) {
      newExpanded.delete(prayerName);
    } else {
      newExpanded.add(prayerName);
    }
    setExpandedPrayers(newExpanded);
  };

  const getCategoryCount = (category: string) => {
    return prayers.filter(p => p.category === category).length;
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      {/* Header */}
      <div className="flex items-center space-x-3 mb-8">
        <Heart className="h-8 w-8 text-catholic-red" />
        <h1 className="text-3xl font-bold font-serif text-gray-900">Catholic Prayers</h1>
      </div>

      {/* Search Bar */}
      <div className="relative mb-6">
        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Search className="h-5 w-5 text-gray-400" />
        </div>
        <input
          type="text"
          placeholder="Search prayers..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-lg focus:ring-catholic-red focus:border-catholic-red"
        />
      </div>

      {/* Category Tabs */}
      <div className="flex flex-wrap gap-3 mb-8">
        {categories.map((category) => (
          <CategoryTab
            key={category.key}
            category={category.key}
            label={category.label}
            icon={category.icon}
            isActive={selectedCategory === category.key}
            onClick={() => setSelectedCategory(category.key)}
            count={getCategoryCount(category.key)}
          />
        ))}
        
        {/* Seasonal Prayers */}
        <div className="flex items-center space-x-2">
          <Filter className="h-4 w-4 text-gray-500" />
          <span className="text-sm font-medium text-gray-600">Seasonal:</span>
        </div>
        
        {seasons.map((season) => (
          <CategoryTab
            key={season.key}
            category={season.key}
            label={season.label}
            icon={<Users className="h-4 w-4" />}
            isActive={selectedCategory === season.key}
            onClick={() => setSelectedCategory(season.key)}
          />
        ))}
      </div>

      {/* Content */}
      {loading ? (
        <LoadingSpinner size="lg" text="Loading prayers..." />
      ) : error ? (
        <ErrorMessage 
          message={error} 
          onRetry={() => fetchPrayers(selectedCategory)}
        />
      ) : filteredPrayers.length === 0 ? (
        <div className="text-center py-12">
          <Heart className="h-16 w-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-gray-600 mb-2">No Prayers Found</h3>
          <p className="text-gray-500">
            {searchTerm 
              ? `No prayers match your search "${searchTerm}"`
              : `No prayers available in the ${selectedCategory} category`
            }
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {filteredPrayers.map((prayer, index) => (
            <PrayerCard
              key={`${prayer.name}-${index}`}
              prayer={prayer}
              isExpanded={expandedPrayers.has(prayer.name)}
              onToggle={() => togglePrayerExpansion(prayer.name)}
            />
          ))}
        </div>
      )}

      {/* Footer Note */}
      {filteredPrayers.length > 0 && (
        <div className="mt-12 bg-gray-50 rounded-lg p-6 text-center">
          <p className="text-gray-600 font-serif italic">
            "Pray without ceasing" - 1 Thessalonians 5:17
          </p>
          <p className="text-sm text-gray-500 mt-2">
            These prayers are part of the rich tradition of Catholic spirituality.
            Use them for personal devotion and meditation.
          </p>
        </div>
      )}
    </div>
  );
};

export default PrayersSection;