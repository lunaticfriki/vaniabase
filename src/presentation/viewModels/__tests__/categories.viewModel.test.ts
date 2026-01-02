
import 'reflect-metadata';
import { mock, instance, when, anything } from 'ts-mockito';
import { CategoriesViewModel } from '../categories.viewModel';
import { ItemStateService } from '../../../application/item/item.stateService';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemReadService } from '../../../application/item/item.readService';
import { ItemWriteService } from '../../../application/item/item.writeService';
import { NotificationService } from '../../../domain/services/notification.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { Category } from '../../../domain/model/entities/category.entity';
import { Id } from '../../../domain/model/value-objects/id.valueObject';
import { Title } from '../../../domain/model/value-objects/stringValues.valueObject';

describe('CategoriesViewModel', () => {
    let mockReadService: ItemReadService;
    let mockWriteService: ItemWriteService;
    let mockAuthService: AuthService;
    let mockNotificationService: NotificationService;
    let itemStateService: ItemStateService;
    let viewModel: CategoriesViewModel;

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

        viewModel = new CategoriesViewModel(itemStateService);
    });

    it('should extract categories from items correctly', async () => {
        const cat1 = Category.create(Id.random(), Title.create('Cat1'));
        const cat2 = Category.create(Id.random(), Title.create('Cat2'));
        const item1 = ItemMother.create({ category: cat1 });
        const item2 = ItemMother.create({ category: cat1 });
        const item3 = ItemMother.create({ category: cat2 });

        when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1, item2, item3]);
        await itemStateService.loadItems();

        const categories = viewModel.categories.value;
        expect(categories).toHaveLength(2);
        
        
        expect(categories[0].name).toBe('cat1');
        expect(categories[0].count).toBe(2);
        
        expect(categories[1].name).toBe('cat2');
        expect(categories[1].count).toBe(1);
    });

    it('should filter items by selected category', async () => {
        const cat1 = Category.create(Id.random(), Title.create('Cat1'));
        const cat2 = Category.create(Id.random(), Title.create('Cat2'));
        const item1 = ItemMother.create({ category: cat1 });
        const item2 = ItemMother.create({ category: cat2 });

        when(mockReadService.findAll(anything() as unknown as Id)).thenResolve([item1, item2]);
        await itemStateService.loadItems();

        viewModel.selectCategory('cat1');
        
        const filteredItems = viewModel.filteredItems.value;
        expect(filteredItems).toHaveLength(1);
        expect(filteredItems[0]).toBe(item1);
    });

    it('should reset page when category changes', () => {
        viewModel.currentPage.value = 5;
        viewModel.selectCategory('new-cat');
        expect(viewModel.currentPage.value).toBe(1);
    });
});
