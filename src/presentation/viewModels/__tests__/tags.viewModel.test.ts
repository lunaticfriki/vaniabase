import 'reflect-metadata';
import { mock, instance, when, verify, anything } from 'ts-mockito';
import { TagsViewModel } from '../tags.viewModel';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemStateService } from '../../../application/item/item.stateService';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { signal } from '@preact/signals';
import { Tags } from '../../../domain/model/value-objects/tags.valueObject';
import { ItemMother } from '../../../domain/__tests__/item.mother';

describe('TagsViewModel', () => {
  let mockReadService: ItemReadService;
  let mockWriteService: ItemWriteService;
  let mockAuthService: AuthService;
  let itemStateService: ItemStateService;
  let viewModel: TagsViewModel;

  beforeEach(() => {
    mockReadService = mock(ItemReadService);
    mockWriteService = mock(ItemWriteService);
    mockAuthService = mock(AuthService);
    when(mockAuthService.currentUser).thenReturn(signal(null));

    itemStateService = new ItemStateService(
      instance(mockReadService),
      instance(mockWriteService),
      instance(mockAuthService)
    );
    viewModel = new TagsViewModel(itemStateService);
  });

  it('should load items on initialization', async () => {
    const items = [ItemMother.create()];
    when(mockReadService.findAll(anything())).thenResolve(items);

    await viewModel.loadItems();

    expect(viewModel.items.value).toEqual(items);
    verify(mockReadService.findAll(anything())).once();
  });

  it('should calculate tag statistics correctly', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['tag1', 'tag2']) });
    const item2 = ItemMother.create({ tags: Tags.create(['tag2', 'tag3']) });
    when(mockReadService.findAll(anything())).thenResolve([item1, item2]);

    await viewModel.loadItems();

    const stats = viewModel.tagData.value;
    expect(stats.tags).toContain('tag1');
    expect(stats.tags).toContain('tag2');
    expect(stats.tags).toContain('tag3');
    expect(stats.counts['tag2']).toBe(2);
    expect(stats.counts['tag1']).toBe(1);
  });

  it('should filter items by active tag', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['A']) });
    const item2 = ItemMother.create({ tags: Tags.create(['B']) });
    when(mockReadService.findAll(anything())).thenResolve([item1, item2]);

    await viewModel.loadItems();
    viewModel.setTag('A');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0]).toBe(item1);
  });

  it('should case-insensitive filter items', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['Apple']) });
    when(mockReadService.findAll(anything())).thenResolve([item1]);

    await viewModel.loadItems();
    viewModel.setTag('apple');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0]).toBe(item1);
  });

  it('should show all items when no tag is selected', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['A']) });
    const item2 = ItemMother.create({ tags: Tags.create(['B']) });
    when(mockReadService.findAll(anything())).thenResolve([item1, item2]);

    await viewModel.loadItems();
    viewModel.setTag('');

    expect(viewModel.filteredItems.value).toHaveLength(2);
  });
});
