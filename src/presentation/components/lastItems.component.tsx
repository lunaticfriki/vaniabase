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
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4 justify-items-center">
        {items.map((item) => (
          <PreviewItemComponent key={item.id} item={item} />
        ))}
      </div>
    </div>
  );
};
