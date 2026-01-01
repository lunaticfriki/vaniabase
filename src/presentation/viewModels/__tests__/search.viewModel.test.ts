
import 'reflect-metadata';
import { mock, instance, when, verify, anything } from 'ts-mockito';
import { SearchViewModel } from '../search.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';

describe('SearchViewModel', () => {
    let mockReadService: ItemReadService;
    let mockWriteService: ItemWriteService;
    let mockAuthService: AuthService;
    let mockNotificationService: NotificationService;
    let itemStateService: ItemStateService;
    let viewModel: SearchViewModel;

    beforeEach(() => {
        mockReadService = mock(ItemReadService);
        mockWriteService = mock(ItemWriteService);
        mockAuthService = mock(AuthService);
        mockNotificationService = mock(NotificationService);

        when(mockAuthService.currentUser).thenReturn(signal(null));
        when(mockReadService.findAll(anything())).thenResolve([]);
        when(mockReadService.search(anything())).thenResolve([]);

        itemStateService = new ItemStateService(
            instance(mockReadService),
            instance(mockWriteService),
            instance(mockAuthService),
            instance(mockNotificationService)
        );

        viewModel = new SearchViewModel(itemStateService);
    });

    it('should search items and update results', async () => {
        const item = ItemMother.create();
        when(mockReadService.search('test')).thenResolve([item]);

        await viewModel.search('test');

        verify(mockReadService.search('test')).once();
        expect(viewModel.items.value).toEqual([item]);
        expect(viewModel.loading.value).toBe(false);
    });

    it('should clear results when query is empty', async () => {
        viewModel.items.value = [ItemMother.create()];
        await viewModel.search('');
        
        expect(viewModel.items.value).toEqual([]);
        expect(viewModel.loading.value).toBe(false);
    });
});
