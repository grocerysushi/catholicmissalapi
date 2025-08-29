import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Header from './components/Layout/Header';
import Footer from './components/Layout/Footer';
import DailyReadings from './components/Readings/DailyReadings';
import LiturgicalCalendar from './components/Calendar/LiturgicalCalendar';
import PrayersSection from './components/Prayers/PrayersSection';
import './App.css';

const App: React.FC = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <Router>
      <div className="min-h-screen bg-gradient-light flex flex-col">
        <Header 
          isMobileMenuOpen={isMobileMenuOpen}
          setIsMobileMenuOpen={setIsMobileMenuOpen}
        />
        
        <main className="flex-grow">
          <Routes>
            <Route path="/" element={<DailyReadings />} />
            <Route path="/calendar" element={<LiturgicalCalendar />} />
            <Route path="/prayers" element={<PrayersSection />} />
          </Routes>
        </main>
        
        <Footer />
      </div>
    </Router>
  );
};

export default App;