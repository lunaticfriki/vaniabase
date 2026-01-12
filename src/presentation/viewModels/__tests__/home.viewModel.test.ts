import 'reflect-metadata';
import { mock, instance, when, verify } from 'ts-mockito';
import { HomeViewModel } from '../home.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { Created } from '../../../domain/model/value-objects/dateAndNumberValues.valueObject';

describe('HomeViewModel', () => {
  let mockItemStateService: ItemStateService;
  let viewModel: HomeViewModel;

  beforeEach(() => {
    mockItemStateService = mock(ItemStateService);
    // Be default return empty list
    when(mockItemStateService.items).thenReturn(signal([]));
    when(mockItemStateService.isLoading).thenReturn(signal(false));

    viewModel = new HomeViewModel(instance(mockItemStateService));
  });

  it('should load items on initialization call', () => {
    viewModel.loadItems();
    verify(mockItemStateService.loadItems()).once();
  });

  it('should return recent items sorted by date descending', () => {
    const now = new Date();
    const item1 = ItemMother.create({ created: Created.create(new Date(now.getTime() - 10000)) }); // Oldest
    const item2 = ItemMother.create({ created: Created.create(new Date(now.getTime() - 5000)) });
    const item3 = ItemMother.create({ created: Created.create(new Date(now.getTime())) }); // Newest

    when(mockItemStateService.items).thenReturn(signal([item1, item2, item3]));
    viewModel = new HomeViewModel(instance(mockItemStateService)); // Re-init to pick up signal ? Or just access computed

    const recent = viewModel.recentItems.value;

    expect(recent).toHaveLength(3);
    expect(recent[0].id.value).toBe(item3.id.value); // Newest first
    expect(recent[1].id.value).toBe(item2.id.value);
    expect(recent[2].id.value).toBe(item1.id.value);
  });

  it('should limit recent items to 5', () => {
    const items = Array.from({ length: 10 }).map((_, i) =>
      ItemMother.create({ created: Created.create(new Date(Date.now() - i * 1000)) })
    );

    when(mockItemStateService.items).thenReturn(signal(items));
    viewModel = new HomeViewModel(instance(mockItemStateService));

    const recent = viewModel.recentItems.value;
    expect(recent).toHaveLength(5);
    // items[0] is newest (Date.now() - 0), items[9] is oldest
    // So recent[0] should be items[0]
    expect(recent[0].id.value).toBe(items[0].id.value);
  });
});
