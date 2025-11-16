import { signal } from '@preact/signals-react';
import { Item } from '../domain/item';
import { ItemsDI } from '../di';

interface ItemsState {
  items: Item[];
  error: string | null;
  loading: boolean;
  categories: string[];
}

const initialState: ItemsState = {
  items: [] as Item[],
  categories: [] as string[],
  error: null,
  loading: false,
};

const state = signal<ItemsState>(initialState);

function createItemReadService() {
  const getItems = async (endpoint: string = '/items'): Promise<void> => {
    state.value = { ...state.value, loading: true, error: null };

    try {
      const items = await ItemsDI.repository.getItems(endpoint);
      state.value = {
        items,
        categories: state.value.categories,
        error: null,
        loading: false,
      };
      ItemsDI.notification.success(`Loaded ${items.length} items successfully`);
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error';
      state.value = {
        ...state.value,
        error: errorMessage,
        loading: false,
      };
      ItemsDI.errorManager.handleError(error as Error);
      ItemsDI.notification.error('Failed to load items', 'Error');
    }
  };

  const getItem = async (id: string, endpoint?: string): Promise<void> => {
    state.value = { ...state.value, loading: true, error: null };

    try {
      const item = await ItemsDI.repository.getItem(endpoint ?? `/items/${id}`);

      const existingIndex = state.value.items.findIndex(
        (i) => i.id === item.id
      );

      let updatedItems: Item[];
      if (existingIndex !== -1) {
        updatedItems = [...state.value.items];
        updatedItems[existingIndex] = item;
      } else {
        updatedItems = [...state.value.items, item];
      }

      state.value = {
        items: updatedItems,
        categories: state.value.categories,
        error: null,
        loading: false,
      };
      ItemsDI.notification.info('Item loaded successfully');
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error';
      state.value = {
        ...state.value,
        error: errorMessage,
        loading: false,
      };
      ItemsDI.errorManager.handleError(error as Error);
      ItemsDI.notification.error('Failed to load item', 'Error');
    }
  };

  const getCategories = () => {
    state.value = { ...state.value, loading: true, error: null };

    try {
      const categories = state.value.items
        .map((item) => item.category)
        .filter((value, index, self) => self.indexOf(value) === index);

      const categoriesSet = new Set(categories);
      const uniqueCategories = Array.from(categoriesSet);
      state.value = {
        ...state.value,
        categories: uniqueCategories,
        loading: false,
      };
      ItemsDI.notification.success(
        `Loaded ${categories.length} categories successfully`
      );
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error';
      state.value = {
        ...state.value,
        error: errorMessage,
        loading: false,
      };
      ItemsDI.errorManager.handleError(error as Error);
      ItemsDI.notification.error('Failed to load categories', 'Error');
    }
  };

  const getItemsByCategory = (category: string): Item[] => {
    return state.value.items.filter((item) => item.category === category);
  };

  const getDefaultCategory = (): string | null => {
    if (state.value.categories.length === 0) {
      return null;
    }

    const booksCategory = state.value.categories.find(
      (cat) => cat.toLowerCase() === 'books'
    );

    if (booksCategory) {
      return booksCategory;
    }

    const categoryWithItems = state.value.categories.find((cat) => {
      const items = getItemsByCategory(cat);
      return items.length > 0;
    });

    return categoryWithItems || state.value.categories[0];
  };

  const getCompletedItems = (): Item[] => {
    return state.value.items.filter((item) => item.completed === true);
  };

  const clearError = (): void => {
    state.value = { ...state.value, error: null };
  };

  const reset = (): void => {
    state.value = initialState;
  };

  return {
    state,
    actions: {
      getItems,
      getCategories,
      getItemsByCategory,
      getDefaultCategory,
      getCompletedItems,
      getItem,
      clearError,
      reset,
    },
  };
}

export const useItemReadService = createItemReadService;
