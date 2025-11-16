import { Link } from 'react-router-dom';

export const ContentComponent = () => {
  return (
    <div className="flex flex-wrap justify-center gap-3 sm:gap-4 my-8 px-4">
      <Link
        to="/all-items"
        className="px-4 sm:px-6 py-2 text-sm sm:text-base text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors whitespace-nowrap"
      >
        All Items
      </Link>
      <Link
        to="/last-items"
        className="px-4 sm:px-6 py-2 text-sm sm:text-base text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors whitespace-nowrap"
      >
        Last Items
      </Link>
      <Link
        to="/search"
        className="px-4 sm:px-6 py-2 text-sm sm:text-base text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors whitespace-nowrap"
      >
        Search
      </Link>
      <Link
        to="/categories"
        className="px-4 sm:px-6 py-2 text-sm sm:text-base text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors whitespace-nowrap"
      >
        Categories
      </Link>
      <Link
        to="/about"
        className="px-4 sm:px-6 py-2 text-sm sm:text-base text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors whitespace-nowrap"
      >
        About
      </Link>
    </div>
  );
};
