import type { Item } from '../../domain/item';
import { PreviewElementComponent } from './previewElement.component';

interface LastElementsProps {
  items: Item[];
}

export const LastElementsComponent = ({ items }: LastElementsProps) => {
  return (
    <div className="p-6">
      <h2 className="text-3xl text-pink-500 mb-6">Last Elements</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6">
        {items.map((item) => (
          <PreviewElementComponent key={item.id} item={item} />
        ))}
      </div>
    </div>
  );
};
