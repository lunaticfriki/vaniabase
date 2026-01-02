
import 'reflect-metadata';
import { mock, instance, when, verify, anything } from 'ts-mockito';
import { EditItemViewModel } from '../editItem.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { Id } from '../../../domain/model/value-objects/id.valueObject';
import { Item } from '../../../domain/model/entities/item.entity';

describe('EditItemViewModel', () => {
    let mockReadService: ItemReadService;
    let mockWriteService: ItemWriteService;
    let mockAuthService: AuthService;
    let mockNotificationService: NotificationService;
    let itemStateService: ItemStateService;
    let viewModel: EditItemViewModel;

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

        viewModel = new EditItemViewModel(itemStateService);
    });

    it('should load an item for editing', async () => {
        const item = ItemMother.create();
        when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item]);
        when(mockReadService.findById(anything() as unknown as Id)).thenResolve(item);
        
        await itemStateService.loadItems();
        await viewModel.loadItem(item.id.value);

        expect(viewModel.item.value).toEqual(item);
        expect(viewModel.formData.value).toBeTruthy();
        expect(viewModel.formData.value?.title).toBe(item.title.value);
    });

    it('should update an item', async () => {
        const item = ItemMother.create();
        viewModel.item.value = item;
        
        const formData = {
            title: 'Updated Title',
            description: item.description.value,
            author: item.author.value,
            cover: item.cover.value,
            tags: item.tags.value.join(', '),
            topic: item.topic.value,
            format: item.format.value,
            created: item.created.value.toISOString().split('T')[0],
            completed: item.completed.value,
            year: item.year.value.toString(),
            publisher: item.publisher.value,
            language: item.language.value,
            category: 'books',
            reference: item.reference.value
        };

        await viewModel.updateItem(formData);

        verify(mockWriteService.update(anything() as unknown as Item)).once();
        expect(viewModel.item.value?.title.value).toBe('Updated Title');
    });
});
