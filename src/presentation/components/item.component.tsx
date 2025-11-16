import type { Item } from '../../domain/item';
import { BackButtonComponent } from './backButton.component';

interface ItemComponentProps {
  item: Item;
}

export const ItemComponent = ({ item }: ItemComponentProps) => {
  return (
    <div className="max-w-6xl mx-auto grid grid-rows-[auto_1fr] h-full relative pt-8">
      <div
        className="absolute inset-0 bg-cover bg-center blur-3xl opacity-20 -z-10"
        style={{ backgroundImage: `url(${item.imageUrl})` }}
      />
      <BackButtonComponent />
      <div className="h-full p-6 flex items-center">
        <div className="flex flex-col md:flex-row md:items-center gap-6 md:gap-8 md:mt-8">
          <div className="flex-1 md:order-1 order-2">
            <h1 className="text-4xl text-white mb-2">{item.name}</h1>
            <p className="text-2xl text-white mb-6">{item.author}</p>

            <div className="space-y-3 text-lg">
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
                <span className="text-white">
                  {item.compeleted ? 'Yes' : 'No'}
                </span>
              </div>

              <div>
                <span className="text-pink-500">Tags: </span>
                <span className="text-white">{item.tags.join(', ')}</span>
              </div>

              <div>
                <span className="text-pink-500">Description: </span>
                <span className="text-white">{item.description}</span>
              </div>
            </div>
          </div>

          <div className="md:order-2 md:shrink-0 order-1">
            <img
              src={item.imageUrl}
              alt={item.name}
              className="cyber-card-image w-full max-w-md mx-auto md:mx-0 md:w-80 aspect-2/3 object-cover"
            />
          </div>
        </div>
      </div>
    </div>
  );
};
