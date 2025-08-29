/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'catholic-red': '#8B0000',
        'catholic-gold': '#FFD700',
        'catholic-purple': '#663399',
        'liturgical': {
          'white': '#FFFFFF',
          'red': '#DC2626',
          'green': '#059669',
          'purple': '#7C3AED',
          'rose': '#EC4899',
          'black': '#1F2937'
        }
      },
      fontFamily: {
        'serif': ['Crimson Text', 'Georgia', 'serif'],
        'sans': ['Inter', 'system-ui', 'sans-serif'],
      },
      backgroundImage: {
        'gradient-catholic': 'linear-gradient(135deg, #8B0000 0%, #A0522D 100%)',
        'gradient-light': 'linear-gradient(135deg, #F8F9FA 0%, #E9ECEF 100%)',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-in': 'slideIn 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideIn: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}