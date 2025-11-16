import { Link } from 'react-router-dom';
import type { Item } from '../../domain/item';

interface PreviewItemProps {
  item: Item;
}

export const PreviewItemComponent = ({ item }: PreviewItemProps) => {
  return (
    <Link to={`/item/${item.id}`} className="cyber-card p-3 max-w-[300px]">
      <div className="flex flex-col items-center">
        <img
          src={item.imageUrl}
          alt={item.name}
          className="cyber-card-image w-full aspect-2/3 object-cover"
        />
        <h3
          data-text={item.name}
          className="cyber-text mt-3 text-pink-500 text-center text-sm line-clamp-2 font-bold uppercase tracking-wide"
        >
          {item.name}
        </h3>
      </div>
    </Link>
  );
};
