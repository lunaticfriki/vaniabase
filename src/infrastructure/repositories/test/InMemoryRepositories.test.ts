import { InMemoryItemsRepository } from '../InMemoryItemsRepository';
import { InMemoryCategoriesRepository } from '../InMemoryCategoriesRepository';
import { ItemMother } from '../../../domain/test/ItemMother';
import { CategoryMother } from '../../../domain/test/CategoryMother';

describe('InMemoryRepositories', () => {
    describe('InMemoryItemsRepository', () => {
        let repository: InMemoryItemsRepository;

        beforeEach(() => {
            repository = new InMemoryItemsRepository();
        });

        it('should be initialized with seed data', async () => {
            const items = await repository.findAll();
            expect(items.length).toBeGreaterThan(0);
        });

        it('should save and find an item', async () => {
            const item = ItemMother.create();
            await repository.save(item);

            const foundItem = await repository.findById(item.id);
            expect(foundItem).toBeDefined();
            expect(foundItem?.id.value).toBe(item.id.value);
        });
    });

    describe('InMemoryCategoriesRepository', () => {
        let repository: InMemoryCategoriesRepository;

        beforeEach(() => {
            repository = new InMemoryCategoriesRepository();
        });

        it('should be initialized with seed data', async () => {
            const categories = await repository.findAll();
            expect(categories.length).toBeGreaterThan(0);
        });

        it('should save and find a category', async () => {
            const category = CategoryMother.create();
            await repository.save(category);

            const foundCategory = await repository.findById(category.id);
            expect(foundCategory).toBeDefined();
            expect(foundCategory?.id.value).toBe(category.id.value);
        });
    });
});
