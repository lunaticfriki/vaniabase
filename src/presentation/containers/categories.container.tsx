import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useItemReadService } from '../../app/item.readService';
import { CategoriesComponent } from '../components/categories.component';
import type { Item } from '../../domain/item';

export const CategoriesContainer = () => {
  const { category } = useParams<{ category?: string }>();
  const navigate = useNavigate();
  const { state, actions } = useItemReadService();
  const [filteredItems, setFilteredItems] = useState<Item[]>([]);

  useEffect(() => {
    if (state.value.items.length > 0) {
      actions.getCategories();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state.value.items.length]);

  useEffect(() => {
    if (!category && state.value.categories.length > 0) {
      const defaultCategory = actions.getDefaultCategory();

      if (defaultCategory) {
        navigate(`/categories/${encodeURIComponent(defaultCategory)}`, {
          replace: true,
        });
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [category, state.value.categories]);

  useEffect(() => {
    if (category) {
      const decodedCategory = decodeURIComponent(category);
      const items = actions.getItemsByCategory(decodedCategory);
      setFilteredItems(items);
    } else {
      setFilteredItems([]);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [category, state.value.items]);

  return (
    <div>
      <CategoriesComponent
        categories={state.value.categories}
        selectedCategory={category ? decodeURIComponent(category) : undefined}
        items={filteredItems}
      />
    </div>
  );
};
