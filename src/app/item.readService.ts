import { signal } from '@preact/signals-react';
import type { Item } from '../domain/item';
import { ItemsDI } from '../di';

interface ItemsState {
  items: Item[];
  error: string | null;
  loading: boolean;
}

const initialState: ItemsState = {
  items: [],
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
      getItem,
      clearError,
      reset,
    },
  };
}

export const useItemReadService = createItemReadService;
