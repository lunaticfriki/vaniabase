import { describe, it, expect, vi, beforeEach } from 'vitest';
import { PublishersViewModel } from '../publishers.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { Item } from '../../../domain/model/entities/item.entity';
import { Signal, signal } from '@preact/signals';
import { Publisher } from '../../../domain/model/value-objects/stringValues.valueObject';

describe('PublishersViewModel', () => {
  let viewModel: PublishersViewModel;
  let mockItemStateService: ItemStateService;
  let itemsSignal: Signal<Item[]>;

  beforeEach(() => {
    itemsSignal = signal<Item[]>([]);
    mockItemStateService = {
      items: itemsSignal,
      isLoading: signal(false),
      loadItems: vi.fn()
    } as unknown as ItemStateService;

    viewModel = new PublishersViewModel(mockItemStateService);
  });

  it('should load items on initialization', () => {
    void viewModel.loadItems();
    // eslint-disable-next-line @typescript-eslint/unbound-method
    const loadItemsSpy = mockItemStateService.loadItems;
    expect(loadItemsSpy).toHaveBeenCalled();
  });

  it('should calculate publisher statistics correctly', () => {
    const item1 = { publisher: Publisher.create('Publisher A') } as Item;
    const item2 = { publisher: Publisher.create('Publisher B') } as Item;
    const item3 = { publisher: Publisher.create('Publisher A') } as Item;

    itemsSignal.value = [item1, item2, item3];

    const stats = viewModel.publisherData.value;
    expect(stats.publishers).toEqual(['Publisher A', 'Publisher B']);
    expect(stats.counts['Publisher A']).toBe(2);
    expect(stats.counts['Publisher B']).toBe(1);
  });

  it('should filter items by active publisher', () => {
    const item1 = { publisher: Publisher.create('Publisher A') } as Item;
    const item2 = { publisher: Publisher.create('Publisher B') } as Item;

    itemsSignal.value = [item1, item2];

    viewModel.setPublisher('Publisher A');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0].publisher.value).toBe('Publisher A');
  });

  it('should case-insensitive filter items', () => {
    const item1 = { publisher: { value: 'Publisher A' } } as Item;

    itemsSignal.value = [item1];

    viewModel.setPublisher('publisher a');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0].publisher.value).toBe('Publisher A');
  });

  it('should show all items when no publisher is selected', () => {
    const item1 = { publisher: Publisher.create('Publisher A') } as Item;
    const item2 = { publisher: Publisher.create('Publisher B') } as Item;

    itemsSignal.value = [item1, item2];

    viewModel.setPublisher(undefined);

    expect(viewModel.filteredItems.value).toHaveLength(2);
  });
});
