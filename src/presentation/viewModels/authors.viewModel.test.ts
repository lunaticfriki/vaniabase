import { describe, it, expect, vi, beforeEach } from 'vitest';
import { AuthorsViewModel } from './authors.viewModel';
import { ItemStateService } from '../../application/item/item.stateService';
import { Item } from '../../domain/model/entities/item.entity';
import { Signal, signal } from '@preact/signals';

describe('AuthorsViewModel', () => {
  let viewModel: AuthorsViewModel;
  let mockItemStateService: ItemStateService;
  let itemsSignal: Signal<Item[]>;

  beforeEach(() => {
    itemsSignal = signal<Item[]>([]);
    mockItemStateService = {
      items: itemsSignal,
      isLoading: signal(false),
      loadItems: vi.fn(),
    } as unknown as ItemStateService;

    viewModel = new AuthorsViewModel(mockItemStateService);
  });

  it('should load items on initialization', () => {
    void viewModel.loadItems();
    // eslint-disable-next-line @typescript-eslint/unbound-method
    const loadItemsSpy = mockItemStateService.loadItems;
    expect(loadItemsSpy).toHaveBeenCalled();
  });

  it('should compute author statistics correctly', () => {
    const item1 = { author: { value: 'Author A' } } as Item;
    const item2 = { author: { value: 'Author A' } } as Item;
    const item3 = { author: { value: 'Author B' } } as Item;
    
    itemsSignal.value = [item1, item2, item3];

    const stats = viewModel.authorData.value;
    expect(stats.authors).toEqual(['Author A', 'Author B']);
    expect(stats.counts['Author A']).toBe(2);
    expect(stats.counts['Author B']).toBe(1);
  });

  it('should filter items by active author', () => {
    const item1 = { author: { value: 'Author A' } } as Item;
    const item2 = { author: { value: 'Author B' } } as Item;
    
    itemsSignal.value = [item1, item2];

    viewModel.setAuthor('Author A');
    
    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0].author.value).toBe('Author A');
  });

  it('should return all items when no author is selected', () => {
    const item1 = { author: { value: 'Author A' } } as Item;
    const item2 = { author: { value: 'Author B' } } as Item;
    
    itemsSignal.value = [item1, item2];

    viewModel.setAuthor(undefined);
    
    expect(viewModel.filteredItems.value).toHaveLength(2);
  });

  it('should paginate items correctly', () => {
    const items = Array.from({ length: 20 }, (_, i) => ({ author: { value: 'Author A' }, id: { value: i } })) as unknown as Item[];
    itemsSignal.value = items;

    // Default 12 items per page
    expect(viewModel.currentItems.value).toHaveLength(12);
    
    viewModel.pagination.goToPage(2);
    expect(viewModel.currentItems.value).toHaveLength(8);
  });
});
