
import 'reflect-metadata';
import { mock, instance, when, anything } from 'ts-mockito';
import { CollectionViewModel } from '../collection.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { Year } from '../../../domain/model/value-objects/dateAndNumberValues.valueObject';

describe('CollectionViewModel', () => {
    let mockReadService: ItemReadService;
    let mockWriteService: ItemWriteService;
    let mockAuthService: AuthService;
    let mockNotificationService: NotificationService;
    let itemStateService: ItemStateService;
    let viewModel: CollectionViewModel;

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

        viewModel = new CollectionViewModel(itemStateService);
    });

    it('should sort items by year descending', async () => {
        const item1 = ItemMother.create({ year: Year.create(2020) });
        const item2 = ItemMother.create({ year: Year.create(2022) });
        when(mockReadService.findAll(anything())).thenResolve([item1, item2]);
        
        await itemStateService.loadItems();
        
        const items = viewModel.allItems.value;
        expect(items[0]).toBe(item2);
        expect(items[1]).toBe(item1);
    });

    it('should handle pagination', async () => {
        const items = Array(25).fill(null).map(() => ItemMother.create());
        when(mockReadService.findAll(anything())).thenResolve(items);
        
        await itemStateService.loadItems();
        viewModel.itemsPerPage = 10;
        
        expect(viewModel.totalPages.value).toBe(3);
        expect(viewModel.paginatedItems.value).toHaveLength(10);
        
        viewModel.setPage(2);
        expect(viewModel.currentPage.value).toBe(2);
        expect(viewModel.paginatedItems.value).toHaveLength(10);
        
        viewModel.setPage(3);
        expect(viewModel.paginatedItems.value).toHaveLength(5);
    });
});
