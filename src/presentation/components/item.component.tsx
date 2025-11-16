import { useNavigate } from 'react-router-dom';
import type { Item } from '../../domain/item';

interface ItemComponentProps {
  item: Item;
}

export const ItemComponent = ({ item }: ItemComponentProps) => {
  const navigate = useNavigate();

  return (
    <div className="max-w-2xl mx-auto p-6">
      <img
        src={item.imageUrl}
        alt={item.name}
        className="w-full max-w-md mx-auto aspect-2/3 object-cover rounded mb-6"
      />

      <h1 className="text-4xl text-white mb-2">{item.name}</h1>
      <p className="text-2xl text-white mb-6">{item.author}</p>

      <div className="space-y-3 text-lg">
        <div>
          <span className="text-pink-500">Description: </span>
          <span className="text-white">{item.description}</span>
        </div>

        <div>
          <span className="text-pink-500">Topic: </span>
          <span className="text-white">{item.topic}</span>
        </div>

        <div>
          <span className="text-pink-500">Year: </span>
          <span className="text-white">{item.year}</span>
        </div>

        <div>
          <span className="text-pink-500">Language: </span>
          <span className="text-white">{item.language}</span>
        </div>

        <div>
          <span className="text-pink-500">Format: </span>
          <span className="text-white">{item.format}</span>
        </div>

        <div>
          <span className="text-pink-500">Owner: </span>
          <span className="text-white">{item.owner}</span>
        </div>

        <div>
          <span className="text-pink-500">Completed: </span>
          <span className="text-white">{item.compeleted ? 'Yes' : 'No'}</span>
        </div>

        <div>
          <span className="text-pink-500">Tags: </span>
          <span className="text-white">{item.tags.join(', ')}</span>
        </div>
      </div>

      <div className="flex justify-center mt-6">
        <button
          onClick={() => navigate(-1)}
          className="px-6 py-2 text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors cursor-pointer"
        >
          Back
        </button>
      </div>
    </div>
  );
};
