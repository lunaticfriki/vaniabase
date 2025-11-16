import { useState, useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';

export const MenuComponent = () => {
  const [isOpen, setIsOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  const menuItems = [
    { path: '/', label: 'Home' },
    { path: '/all-items', label: 'All Items' },
    { path: '/last-items', label: 'Last Items' },
    { path: '/search', label: 'Search' },
    { path: '/categories', label: 'Categories' },
    { path: '/about', label: 'About' },
  ];

  return (
    <div className="relative" ref={menuRef}>
      <button
        onClick={toggleMenu}
        className="cyber-menu-toggle text-pink-500 hover:text-white"
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
        <div
          className="fixed md:absolute inset-0 md:inset-auto md:right-0 md:top-full md:mt-2 bg-pink-500 md:bg-[rgb(11,3,15)] border-0 md:border-2 md:border-pink-500 p-6 md:min-w-[200px] z-50"
          style={{
            clipPath:
              'polygon(0 0, calc(100% - 16px) 0, 100% 16px, 100% 100%, 16px 100%, 0 calc(100% - 16px))',
          }}
        >
          <button
            onClick={toggleMenu}
            className="cyber-menu-toggle absolute top-4 right-4 text-white md:hidden"
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
          <ul className="list-none space-y-4 md:space-y-4">
            {menuItems.map((item) => (
              <li key={item.path}>
                <Link
                  to={item.path}
                  onClick={() => setIsOpen(false)}
                  data-text={item.label}
                  className="cyber-button block text-center text-white md:text-pink-500"
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
