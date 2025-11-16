import { Link } from 'react-router-dom';
import type { Item } from '../../domain/item';
import { PreviewItemComponent } from './previewItem.component';

export const CategoriesComponent = ({
  categories,
  selectedCategory,
  items,
}: {
  categories: string[];
  selectedCategory?: string;
  items?: Item[];
}) => {
  return (
    <div className="flex flex-col gap-8">
      <div className="flex flex-wrap justify-center gap-3 sm:gap-4 my-8 px-4">
        {categories.map((category) => (
          <Link
            key={category}
            to={`/categories/${encodeURIComponent(category)}`}
            data-text={category}
            className="cyber-button text-pink-500 hover:text-white text-sm sm:text-base whitespace-nowrap"
          >
            {category}
          </Link>
        ))}
      </div>

      {selectedCategory && items && items.length > 0 && (
        <div className="px-4">
          <h2 className="text-2xl text-pink-500 font-bold mb-6 text-center">
            {selectedCategory}
          </h2>
          <div className="flex flex-wrap justify-center gap-4 md:gap-6">
            {items.map((item) => (
              <PreviewItemComponent key={item.id} item={item} />
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
