import React from 'react';
import { Heart, ExternalLink } from 'lucide-react';

const Footer: React.FC = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-gray-900 text-gray-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* About */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4 font-serif">
              About Catholic Missal
            </h3>
            <p className="text-sm leading-relaxed">
              A digital companion for Catholic liturgical life, providing daily Mass readings, 
              liturgical calendar information, and traditional prayers to support your spiritual journey.
            </p>
          </div>

          {/* Data Sources */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4 font-serif">
              Data Sources
            </h3>
            <ul className="text-sm space-y-2">
              <li className="flex items-center">
                <ExternalLink className="h-3 w-3 mr-2" />
                <span>USCCB (United States Conference of Catholic Bishops)</span>
              </li>
              <li className="flex items-center">
                <ExternalLink className="h-3 w-3 mr-2" />
                <span>Vatican Official Sources</span>
              </li>
              <li className="flex items-center">
                <ExternalLink className="h-3 w-3 mr-2" />
                <span>Licensed Catholic Publishers</span>
              </li>
              <li className="flex items-center">
                <ExternalLink className="h-3 w-3 mr-2" />
                <span>Academic Institutions</span>
              </li>
            </ul>
          </div>

          {/* Copyright Notice */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4 font-serif">
              Copyright Notice
            </h3>
            <p className="text-sm leading-relaxed">
              All liturgical texts are used in accordance with Church policies and fair use guidelines. 
              This app is intended for educational and religious purposes.
            </p>
            <p className="text-xs mt-3 text-gray-400">
              For commercial use, please ensure proper licensing from source authorities.
            </p>
          </div>
        </div>

        <div className="mt-8 pt-8 border-t border-gray-800">
          <div className="flex flex-col md:flex-row justify-between items-center">
            <div className="flex items-center space-x-2 text-sm">
              <span>Made with</span>
              <Heart className="h-4 w-4 text-red-500" />
              <span>for the Catholic community</span>
            </div>
            <div className="mt-4 md:mt-0 text-sm text-gray-400">
              © {currentYear} Catholic Missal App. All rights reserved.
            </div>
          </div>
          <div className="mt-4 text-center">
            <p className="text-sm text-gray-400 font-serif italic">
              Ad Majorem Dei Gloriam - For the Greater Glory of God
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;