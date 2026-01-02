
import 'reflect-metadata';
import { mock, instance, when, verify, anything } from 'ts-mockito';
import { ItemDetailViewModel } from '../itemDetail.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { Id } from '../../../domain/model/value-objects/id.valueObject';
import { Item } from '../../../domain/model/entities/item.entity';

describe('ItemDetailViewModel', () => {
  let mockReadService: ItemReadService;
  let mockWriteService: ItemWriteService;
  let mockAuthService: AuthService;
  let mockNotificationService: NotificationService;
  let itemStateService: ItemStateService;
  let viewModel: ItemDetailViewModel;

  beforeEach(() => {
    mockReadService = mock(ItemReadService);
    mockWriteService = mock(ItemWriteService);
    mockAuthService = mock(AuthService);
    mockNotificationService = mock(NotificationService);

    when(mockAuthService.currentUser).thenReturn(signal(null));
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([]);

    itemStateService = new ItemStateService(
      instance(mockReadService),
      instance(mockWriteService),
      instance(mockAuthService),
      instance(mockNotificationService)
    );

    viewModel = new ItemDetailViewModel(itemStateService);
  });

  it('should load an item successfully', async () => {
    const item = ItemMother.create();
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item]);
    
    await itemStateService.loadItems();
    
    await viewModel.loadItem(item.id.value);
    
    expect(viewModel.item.value).toEqual(item);
    expect(viewModel.loading.value).toBe(false);
  });

  it('should handle item not found', async () => {
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([]);
    await itemStateService.loadItems();

    await viewModel.loadItem('non-existent-id');
    
    expect(viewModel.item.value).toBeNull();
    expect(viewModel.loading.value).toBe(false);
  });

  it('should look up item if not in state', async () => {
    const item = ItemMother.create();
    
    itemStateService.items.value = [];
    
    itemStateService.items.value = [];
    
    when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item]);
    
    await viewModel.loadItem(item.id.value);
    
    verify(mockReadService.findAll(anything() as unknown as Id)).times(1);
    expect(viewModel.item.value).toEqual(item);
  });

  it('should toggle item completion status', async () => {
    const incompleteItem = ItemMother.create(); 
    
    viewModel.item.value = incompleteItem;
    const initialStatus = incompleteItem.completed.value;

    await viewModel.toggleComplete();

    verify(mockWriteService.update(anything() as unknown as Item)).once();
    expect(viewModel.item.value?.completed.value).toBe(!initialStatus);
  });

  it('should delete an item', async () => {
    const item = ItemMother.create();
    viewModel.item.value = item;

    await viewModel.deleteItem();

    verify(mockWriteService.delete(anything() as unknown as Id)).once();
  });
});
