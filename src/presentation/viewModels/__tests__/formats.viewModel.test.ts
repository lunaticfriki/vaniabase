import 'reflect-metadata';
import { mock, instance, when, anything } from 'ts-mockito';
import { FormatsViewModel } from '../formats.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { Format } from '../../../domain/model/value-objects/stringValues.valueObject';
import { Id } from '../../../domain/model/value-objects/id.valueObject';
import { Item } from '../../../domain/model/entities/item.entity';

describe('FormatsViewModel', () => {
  let mockReadService: ItemReadService;
  let mockWriteService: ItemWriteService;
  let mockAuthService: AuthService;
  let mockNotificationService: NotificationService;
  let viewModel: FormatsViewModel;

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

    viewModel = new FormatsViewModel(itemStateService);
  });

  it('should filter items by format', async () => {
    const item1 = ItemMother.create({ format: Format.create('Digital') });
    const item2 = ItemMother.create({ format: Format.create('Physical') });

    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1, item2]);
    await viewModel.loadItems();

    viewModel.setFormat('Digital');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0]).toBe(item1);
  });

  it('should case-insensitive filter items by format', async () => {
    const item1 = ItemMother.create({ format: Format.create('Digital') });
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1]);
    await viewModel.loadItems();

    viewModel.setFormat('digital');

    expect(viewModel.filteredItems.value).toHaveLength(1);
    expect(viewModel.filteredItems.value[0]).toBe(item1);
  });

  it('should show all items when no format is selected', async () => {
    const item1 = ItemMother.create({ format: Format.create('Digital') });
    const item2 = ItemMother.create({ format: Format.create('Physical') });
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1, item2]);
    await viewModel.loadItems();
    viewModel.setFormat('');

    expect(viewModel.filteredItems.value).toHaveLength(2);
  });

  it('should update pagination total items when filters change', async () => {
    const item1 = ItemMother.create({ format: Format.create('Digital') });
    const item2 = ItemMother.create({ format: Format.create('Physical') });
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1, item2]);
    await viewModel.loadItems();

    expect(viewModel.pagination.totalItems.value).toBe(2);

    viewModel.setFormat('Digital');

    expect(viewModel.pagination.totalItems.value).toBe(1);
  });

  it('should correctly calculate font size class based on count', async () => {
    const items = [
      ...Array(10).fill(ItemMother.create({ format: Format.create('Common') })) as Item[],
      ...Array(5).fill(ItemMother.create({ format: Format.create('Medium') })) as Item[],
      ...Array(1).fill(ItemMother.create({ format: Format.create('Rare') })) as Item[]
    ];

    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve(items);
    await viewModel.loadItems();

    expect(viewModel.getFontSizeClass(10)).toBe('text-3xl font-black');
    expect(viewModel.getFontSizeClass(5)).toBe('text-xl');
    expect(viewModel.getFontSizeClass(1)).toBe('text-sm');

    expect(viewModel.getFontSizeClass(10)).toBe('text-3xl font-black');
    expect(viewModel.getFontSizeClass(5)).toBe('text-xl');
    expect(viewModel.getFontSizeClass(1)).toBe('text-sm');
  });
});
