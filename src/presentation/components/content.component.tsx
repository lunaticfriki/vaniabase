import { Link } from 'react-router-dom';

export const ContentComponent = () => {
  return (
    <div className="flex flex-wrap justify-center gap-3 sm:gap-4 my-8 px-4">
      <Link
        to="/all-items"
        data-text="All Items"
        className="cyber-button text-pink-500 hover:text-white text-sm sm:text-base whitespace-nowrap"
      >
        All Items
      </Link>
      <Link
        to="/last-items"
        data-text="Last Items"
        className="cyber-button text-pink-500 hover:text-white text-sm sm:text-base whitespace-nowrap"
      >
        Last Items
      </Link>
      <Link
        to="/completed"
        data-text="Completed"
        className="cyber-button text-pink-500 hover:text-white text-sm sm:text-base whitespace-nowrap"
      >
        Completed
      </Link>
      <Link
        to="/search"
        data-text="Search"
        className="cyber-button text-pink-500 hover:text-white text-sm sm:text-base whitespace-nowrap"
      >
        Search
      </Link>
      <Link
        to="/categories"
        data-text="Categories"
        className="cyber-button text-pink-500 hover:text-white text-sm sm:text-base whitespace-nowrap"
      >
        Categories
      </Link>
      <Link
        to="/about"
        data-text="About"
        className="cyber-button text-pink-500 hover:text-white text-sm sm:text-base whitespace-nowrap"
      >
        About
      </Link>
    </div>
  );
};
