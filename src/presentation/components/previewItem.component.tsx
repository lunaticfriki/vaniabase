import { Link } from 'react-router-dom';
import type { Item } from '../../domain/item';

interface PreviewItemProps {
  item: Item;
}

export const PreviewItemComponent = ({ item }: PreviewItemProps) => {
  return (
    <Link
      to={`/item/${item.id}`}
      className="cyber-card p-4 w-[200px] md:w-[250px] lg:w-[300px] flex flex-col"
    >
      <div className="flex flex-col items-center">
        <div className="w-full h-[280px] md:h-[340px] lg:h-[400px] flex items-center justify-center">
          <img
            src={item.imageUrl}
            alt={item.name}
            className="cyber-card-image max-w-full max-h-full w-auto h-auto object-contain"
          />
        </div>
        <h3
          data-text={item.name}
          className="cyber-text mt-4 mb-2 h-[60px] md:h-[70px] overflow-y-auto scrollbar-hide text-pink-500 text-center text-xs md:text-sm font-bold uppercase tracking-wide leading-relaxed"
        >
          {item.name}
        </h3>
      </div>
    </Link>
  );
};
