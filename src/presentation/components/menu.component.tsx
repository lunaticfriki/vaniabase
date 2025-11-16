import { useState } from 'react';
import { Link } from 'react-router-dom';

export const MenuComponent = () => {
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  const menuItems = [
    { path: '/', label: 'Home' },
    { path: '/about', label: 'About' },
  ];

  return (
    <div className="relative">
      <button
        onClick={toggleMenu}
        className="text-pink-500 hover:text-white cursor-pointer p-2 transition-colors"
        aria-label="Toggle menu"
      >
        <svg
          className="w-8 h-8"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M4 6h16M4 12h16M4 18h16"
          />
        </svg>
      </button>

      {isOpen && (
        <div className="fixed md:absolute inset-0 md:inset-auto md:right-0 md:top-full md:mt-2 bg-pink-500 md:bg-[rgb(11,3,15)] border-0 md:border-2 md:border-pink-500 md:rounded p-6 md:min-w-[200px] z-50">
          <button
            onClick={toggleMenu}
            className="absolute top-4 right-4 text-white hover:text-[rgb(11,3,15)] cursor-pointer p-2 transition-colors md:hidden"
            aria-label="Close menu"
          >
            <svg
              className="w-8 h-8"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
          <ul className="list-disc list-inside space-y-4 md:space-y-4">
            {menuItems.map((item) => (
              <li
                key={item.path}
                className="text-white md:text-pink-500 hover:text-[rgb(11,3,15)] md:hover:text-white transition-colors text-lg"
              >
                <Link
                  to={item.path}
                  onClick={() => setIsOpen(false)}
                  className="cursor-pointer"
                >
                  {item.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
};
