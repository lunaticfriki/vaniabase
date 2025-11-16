import { Link } from 'react-router-dom';
import type { Item } from '../../domain/item';

interface PreviewElementProps {
  item: Item;
}

export const PreviewElementComponent = ({ item }: PreviewElementProps) => {
  return (
    <Link
      to={`/item/${item.id}`}
      className="block cursor-pointer hover:opacity-80 transition-opacity"
    >
      <div className="flex flex-col items-center max-w-[300px]">
        <img
          src={item.imageUrl}
          alt={item.name}
          className="w-full aspect-2/3 object-cover rounded"
        />
        <h3 className="mt-2 text-white text-center text-sm line-clamp-2">
          {item.name}
        </h3>
      </div>
    </Link>
  );
};
