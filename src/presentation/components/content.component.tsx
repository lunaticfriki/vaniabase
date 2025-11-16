import { Link } from 'react-router-dom';

export const ContentComponent = () => {
  return (
    <div className="flex justify-center gap-4 my-8">
      <Link
        to="/all-items"
        className="px-6 py-2 text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors"
      >
        All Items
      </Link>
      <Link
        to="/last-items"
        className="px-6 py-2 text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors"
      >
        Last Items
      </Link>
      <Link
        to="/search"
        className="px-6 py-2 text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors"
      >
        Search
      </Link>
      <Link
        to="/categories"
        className="px-6 py-2 text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors"
      >
        Categories
      </Link>
    </div>
  );
};
