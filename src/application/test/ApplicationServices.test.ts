import 'reflect-metadata';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../item/item.stateService';
import { ItemReadService } from '../item/item.readService';
import { ItemWriteService } from '../item/item.writeService';
import { CategoryStateService } from '../category/category.stateService';
import { ItemMother } from '../../domain/test/ItemMother';
import { CategoryMother } from '../../domain/test/CategoryMother';

describe('Application Services & DI', () => {
    describe('Item Services', () => {
        let stateService: ItemStateService;
        let readService: ItemReadService;
        let writeService: ItemWriteService;

        beforeEach(() => {
            stateService = container.get(ItemStateService);
            readService = container.get(ItemReadService);
            writeService = container.get(ItemWriteService);
        });

        it('should resolve all services', () => {
            expect(stateService).toBeDefined();
            expect(readService).toBeDefined();
            expect(writeService).toBeDefined();
        });

        it('should load initial items from seed', async () => {
            await stateService.loadItems();
            expect(stateService.items.value.length).toBeGreaterThan(0);
        });

        it('should create and update state', async () => {
            const newItem = ItemMother.create();
            await stateService.createItem(newItem);
            
            const foundItem = stateService.items.value.find(i => i.id.value === newItem.id.value);
            expect(foundItem).toBeDefined();
            expect(foundItem?.title.value).toBe(newItem.title.value);
        });
    });

    describe('Category Services', () => {
        let stateService: CategoryStateService;

        beforeEach(() => {
            stateService = container.get(CategoryStateService);
        });

        it('should resolve and load categories', async () => {
             expect(stateService).toBeDefined();
             await stateService.loadCategories();
             expect(stateService.categories.value.length).toBeGreaterThan(0);
        });

        it('should create a new category', async () => {
            const newCategory = CategoryMother.create();
            await stateService.createCategory(newCategory);

            const foundCategory = stateService.categories.value.find(c => c.id.value === newCategory.id.value);
            expect(foundCategory).toBeDefined();
        });
    });
});
