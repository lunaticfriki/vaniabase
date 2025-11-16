import { signal } from '@preact/signals-react';
import type { Item } from '../domain/item';
import { ItemsDI } from '../di';

interface ItemWriteState {
  error: string | null;
  loading: boolean;
}

const initialState: ItemWriteState = {
  error: null,
  loading: false,
};

const state = signal<ItemWriteState>(initialState);

function createItemWriteService() {
  const createItem = async (
    data: Item,
    endpoint: string = '/items'
  ): Promise<void> => {
    state.value = { loading: true, error: null };

    try {
      await ItemsDI.repository.postItem(endpoint, data);
      state.value = {
        error: null,
        loading: false,
      };
      ItemsDI.notification.success('Item created successfully');
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error';
      state.value = {
        error: errorMessage,
        loading: false,
      };
      ItemsDI.errorManager.handleError(error as Error);
      ItemsDI.notification.error('Failed to create item', 'Error');
    }
  };

  const updateItem = async (
    id: string,
    data: Item,
    endpoint?: string
  ): Promise<void> => {
    state.value = { loading: true, error: null };

    try {
      await ItemsDI.repository.putItem(endpoint ?? `/items/${id}`, data);
      state.value = {
        error: null,
        loading: false,
      };
      ItemsDI.notification.success('Item updated successfully');
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error';
      state.value = {
        error: errorMessage,
        loading: false,
      };
      ItemsDI.errorManager.handleError(error as Error);
      ItemsDI.notification.error('Failed to update item', 'Error');
    }
  };

  const deleteItem = async (id: string, endpoint?: string): Promise<void> => {
    state.value = { loading: true, error: null };

    try {
      await ItemsDI.repository.deleteItem(endpoint ?? `/items/${id}`);
      state.value = {
        error: null,
        loading: false,
      };
      ItemsDI.notification.success('Item deleted successfully');
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error';
      state.value = {
        error: errorMessage,
        loading: false,
      };
      ItemsDI.errorManager.handleError(error as Error);
      ItemsDI.notification.error('Failed to delete item', 'Error');
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
      createItem,
      updateItem,
      deleteItem,
      clearError,
      reset,
    },
  };
}

export const useItemWriteService = createItemWriteService;
