import 'reflect-metadata';
import { mock, instance, when, verify } from 'ts-mockito';
import { TagsViewModel } from '../TagsViewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { ItemMother } from '../../../domain/test/ItemMother';
import { Tags } from '../../../domain/model/value-objects/Tags';

describe('TagsViewModel', () => {
  let mockReadService: ItemReadService;
  let mockWriteService: ItemWriteService;
  let itemStateService: ItemStateService;
  let viewModel: TagsViewModel;

  beforeEach(() => {
    mockReadService = mock(ItemReadService);
    mockWriteService = mock(ItemWriteService);
    itemStateService = new ItemStateService(
      instance(mockReadService),
      instance(mockWriteService)
    );
    viewModel = new TagsViewModel(itemStateService);
  });

  it('should load items on initialization', async () => {
    const items = [ItemMother.create()];
    when(mockReadService.findAll()).thenResolve(items);

    await viewModel.loadItems();

    expect(viewModel.items.value).toEqual(items);
    verify(mockReadService.findAll()).once();
  });

  it('should calculate tag statistics correctly', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['tag1', 'tag2']) });
    const item2 = ItemMother.create({ tags: Tags.create(['tag2', 'tag3']) });
    when(mockReadService.findAll()).thenResolve([item1, item2]);

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
    when(mockReadService.findAll()).thenResolve([item1, item2]);

    await viewModel.loadItems();
    viewModel.setTag('A');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0]).toBe(item1);
  });

  it('should case-insensitive filter items', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['Apple']) });
    when(mockReadService.findAll()).thenResolve([item1]);

    await viewModel.loadItems();
    viewModel.setTag('apple');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0]).toBe(item1);
  });

  it('should show all items when no tag is selected', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['A']) });
    const item2 = ItemMother.create({ tags: Tags.create(['B']) });
    when(mockReadService.findAll()).thenResolve([item1, item2]);

    await viewModel.loadItems();
    viewModel.setTag('');

    expect(viewModel.filteredItems.value).toHaveLength(2);
  });
});
