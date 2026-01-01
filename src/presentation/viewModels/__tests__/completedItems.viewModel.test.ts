
import 'reflect-metadata';
import { mock, instance, when, anything } from 'ts-mockito';
import { CompletedItemsViewModel } from '../completedItems.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { Completed } from '../../../domain/model/value-objects/dateAndNumberValues.valueObject';

describe('CompletedItemsViewModel', () => {
    let mockReadService: ItemReadService;
    let mockWriteService: ItemWriteService;
    let mockAuthService: AuthService;
    let mockNotificationService: NotificationService;
    let itemStateService: ItemStateService;
    let viewModel: CompletedItemsViewModel;

    beforeEach(() => {
        mockReadService = mock(ItemReadService);
        mockWriteService = mock(ItemWriteService);
        mockAuthService = mock(AuthService);
        mockNotificationService = mock(NotificationService);

        when(mockAuthService.currentUser).thenReturn(signal(null));
        when(mockReadService.findAll(anything())).thenResolve([]);

        itemStateService = new ItemStateService(
            instance(mockReadService),
            instance(mockWriteService),
            instance(mockAuthService),
            instance(mockNotificationService)
        );

        viewModel = new CompletedItemsViewModel(itemStateService);
    });

    it('should filter only completed items', async () => {
        const completedItem = ItemMother.create({ completed: Completed.create(true) });
        const pendingItem = ItemMother.create({ completed: Completed.create(false) });
        when(mockReadService.findAll(anything())).thenResolve([completedItem, pendingItem]);
        
        await itemStateService.loadItems();
        
        const items = viewModel.allCompletedItems.value;
        expect(items).toHaveLength(1);
        expect(items[0]).toBe(completedItem);
    });

    it('should handle pagination for completed items', async () => {
        const items = Array(15).fill(null).map(() => ItemMother.create({ completed: Completed.create(true) }));
        when(mockReadService.findAll(anything())).thenResolve(items);
        
        await itemStateService.loadItems();
        viewModel.itemsPerPage = 10;
        
        expect(viewModel.totalPages.value).toBe(2);
        expect(viewModel.paginatedItems.value).toHaveLength(10);
    });
});
