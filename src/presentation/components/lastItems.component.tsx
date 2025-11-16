import type { Item } from '../../domain/item';
import { PreviewItemComponent } from './previewItem.component';

interface LastItemsProps {
  items: Item[];
  showTitle?: boolean;
}

export const LastItemsComponent = ({
  items,
  showTitle = true,
}: LastItemsProps) => {
  return (
    <div className="p-6">
      {showTitle && <h2 className="text-3xl text-pink-500 mb-6">Last Items</h2>}
      <div className="flex py-4 gap-4 overflow-x-auto md:grid md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 md:justify-items-center scrollbar-hide snap-x snap-mandatory">
        {items.map((item) => (
          <div key={item.id} className="shrink-0 snap-start">
            <PreviewItemComponent item={item} />
          </div>
        ))}
      </div>
    </div>
  );
};
