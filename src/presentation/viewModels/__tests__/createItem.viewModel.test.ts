import 'reflect-metadata';
import { mock, instance, when, verify, anything } from 'ts-mockito';
import { CreateItemViewModel } from '../createItem.viewModel';

import { Id } from '../../../domain/model/value-objects/id.valueObject';
import { Item } from '../../../domain/model/entities/item.entity';
import { ItemStateService } from '../../../application/item/item.stateService';
import { ImageLookupService } from '../../../infrastructure/services/imageLookupService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';




describe('CreateItemViewModel', () => {
    let mockReadService: ItemReadService;
    let mockWriteService: ItemWriteService;
    let mockAuthService: AuthService;
    let mockNotificationService: NotificationService;
    let mockImageLookupService: ImageLookupService;
    let itemStateService: ItemStateService;
    let viewModel: CreateItemViewModel;

    beforeEach(() => {
        mockReadService = mock(ItemReadService);
        mockWriteService = mock(ItemWriteService);
        mockAuthService = mock(AuthService);
        mockNotificationService = mock(NotificationService);
        mockImageLookupService = mock(ImageLookupService);

        when(mockAuthService.currentUser).thenReturn(signal(null));
        when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([]);
        when(mockImageLookupService.findImage(anything() as unknown as string)).thenResolve('http://example.com/image.jpg');

        itemStateService = new ItemStateService(
            instance(mockReadService),
            instance(mockWriteService),
            instance(mockAuthService),
            instance(mockNotificationService)
        );

        viewModel = new CreateItemViewModel(itemStateService, instance(mockImageLookupService));
    });

    it('should create an item successfully', async () => {
        const formData = {
            title: 'New Item',
            description: 'Desc',
            author: 'Me',
            cover: '',
            tags: 'tag1, tag2',
            topic: 'Tech',
            format: 'Digital',
            created: '2023-01-01',
            completed: false,
            year: '2023',
            publisher: 'Pub',
            language: 'En',
            category: 'books',
            reference: '123'
        };
        const userId = 'user-123';

        await viewModel.createItem(formData, userId);

        verify(mockImageLookupService.findImage('New Item')).once();
        verify(mockWriteService.create(anything() as unknown as Item)).once();
    });


});
