/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inconsolata', 'system-ui', 'sans-serif']
      },
      colors: {
        'brand-violet': '#2E004F', // Dark Violet
        'brand-magenta': '#FF00FF', // Magenta
        'brand-yellow': '#FFFF00' // Yellow
      }
    }
  },
  plugins: []
};
