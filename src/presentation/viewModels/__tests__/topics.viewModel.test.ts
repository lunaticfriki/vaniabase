import 'reflect-metadata';
import { mock, instance, when, anything } from 'ts-mockito';
import { TopicsViewModel } from '../topics.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { Topic } from '../../../domain/model/value-objects/stringValues.valueObject';
import { Id } from '../../../domain/model/value-objects/id.valueObject';
import { Item } from '../../../domain/model/entities/item.entity';

describe('TopicsViewModel', () => {
  let mockReadService: ItemReadService;
  let mockWriteService: ItemWriteService;
  let mockAuthService: AuthService;
  let mockNotificationService: NotificationService;
  let viewModel: TopicsViewModel;

  beforeEach(() => {
    mockReadService = mock(ItemReadService);
    mockWriteService = mock(ItemWriteService);
    mockAuthService = mock(AuthService);
    mockNotificationService = mock(NotificationService);

    when(mockAuthService.currentUser).thenReturn(signal(null));
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([]);

    const itemStateService = new ItemStateService(
      instance(mockReadService),
      instance(mockWriteService),
      instance(mockAuthService),
      instance(mockNotificationService)
    );
    viewModel = new TopicsViewModel(itemStateService);
  });

  it('should filter items by topic', async () => {
    const item1 = ItemMother.create({ topic: Topic.create('History') });
    const item2 = ItemMother.create({ topic: Topic.create('Science') });
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1, item2]);

    await viewModel.loadItems();
    viewModel.setTopic('History');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0]).toBe(item1);
  });

  it('should case-insensitive filter items by topic', async () => {
    const item1 = ItemMother.create({ topic: Topic.create('History') });
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1]);

    await viewModel.loadItems();
    viewModel.setTopic('history');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0]).toBe(item1);
  });

  it('should show all items when no topic is selected', async () => {
    const item1 = ItemMother.create({ topic: Topic.create('History') });
    const item2 = ItemMother.create({ topic: Topic.create('Science') });
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1, item2]);

    await viewModel.loadItems();
    viewModel.setTopic('');

    expect(viewModel.filteredItems.value).toHaveLength(2);
  });

  it('should update pagination total items when filters change', async () => {
    const item1 = ItemMother.create({ topic: Topic.create('History') });
    const item2 = ItemMother.create({ topic: Topic.create('Science') });
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1, item2]);

    await viewModel.loadItems();

    expect(viewModel.pagination.totalItems.value).toBe(2);
    viewModel.setTopic('History');
    expect(viewModel.pagination.totalItems.value).toBe(1);
  });

  it('should correctly calculate font size class based on count', async () => {
    const items = [
      ...Array(10).fill(ItemMother.create({ topic: Topic.create('Common') })) as Item[],
      ...Array(5).fill(ItemMother.create({ topic: Topic.create('Medium') })) as Item[],
      ...Array(1).fill(ItemMother.create({ topic: Topic.create('Rare') })) as Item[]
    ];

    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve(items);

    await viewModel.loadItems();

    expect(viewModel.getFontSizeClass(10)).toBe('text-3xl font-black');
    expect(viewModel.getFontSizeClass(5)).toBe('text-xl');
    expect(viewModel.getFontSizeClass(1)).toBe('text-sm');
  });
});
