import 'reflect-metadata';
import { mock, instance, when, verify, anyString } from 'ts-mockito';
import { ItemStateService } from '../item/item.stateService';
import { ItemReadService } from '../item/item.readService';
import { ItemWriteService } from '../item/item.writeService';
import { CategoryStateService } from '../category/category.stateService';
import { CategoryReadService } from '../category/category.readService';
import { CategoryWriteService } from '../category/category.writeService';
import { ItemsRepository } from '../../domain/repositories/ItemsRepository';
import { ErrorManager } from '../../domain/services/ErrorManager';
import { NotificationService } from '../../domain/services/NotificationService';
import { ItemMother } from '../../domain/test/ItemMother';
import { CategoryMother } from '../../domain/test/CategoryMother';

describe('Application Services (Unit Tests)', () => {
  describe('ItemReadService', () => {
    it('should find all items using repository', async () => {
      const mockRepo = mock<ItemsRepository>();
      const expectedItems = [ItemMother.create()];
      when(mockRepo.findAll()).thenResolve(expectedItems);

      const service = new ItemReadService(instance(mockRepo));
      const items = await service.findAll();

      expect(items).toBe(expectedItems);
      verify(mockRepo.findAll()).once();
    });
  });

  describe('ItemWriteService', () => {
    let mockRepo: ItemsRepository;
    let mockErrorManager: ErrorManager;
    let mockNotificationService: NotificationService;
    let service: ItemWriteService;

    beforeEach(() => {
      mockRepo = mock<ItemsRepository>();
      mockErrorManager = mock<ErrorManager>();
      mockNotificationService = mock<NotificationService>();
      service = new ItemWriteService(
        instance(mockRepo),
        instance(mockErrorManager),
        instance(mockNotificationService)
      );
    });

    it('should create item and notify success', async () => {
      const item = ItemMother.create();
      when(mockRepo.save(item)).thenResolve();

      await service.create(item);

      verify(mockRepo.save(item)).once();
      verify(mockNotificationService.notify(anyString())).once();
    });

    it('should handle error when creation fails', async () => {
      const item = ItemMother.create();
      const error = new Error('Failed');
      when(mockRepo.save(item)).thenReject(error);

      await expect(service.create(item)).rejects.toThrow(error);

      verify(mockRepo.save(item)).once();
      verify(mockErrorManager.handleError(error)).once();
    });
  });

  describe('ItemStateService', () => {
    let mockReadService: ItemReadService;
    let mockWriteService: ItemWriteService;
    let service: ItemStateService;

    beforeEach(() => {
      mockReadService = mock(ItemReadService);
      mockWriteService = mock(ItemWriteService);
      service = new ItemStateService(
        instance(mockReadService),
        instance(mockWriteService)
      );
    });

    it('should load items and update signal', async () => {
      const items = [ItemMother.create()];
      when(mockReadService.findAll()).thenResolve(items);

      await service.loadItems();

      expect(service.items.value).toEqual(items);
      verify(mockReadService.findAll()).once();
    });

    it('should create item and reload', async () => {
      const item = ItemMother.create();
      when(mockWriteService.create(item)).thenResolve();
      when(mockReadService.findAll()).thenResolve([item]);

      await service.createItem(item);

      verify(mockWriteService.create(item)).once();
      verify(mockReadService.findAll()).once();
      expect(service.items.value).toEqual([item]);
    });
  });

  describe('CategoryStateService', () => {
    let mockReadService: CategoryReadService;
    let mockWriteService: CategoryWriteService;
    let service: CategoryStateService;

    beforeEach(() => {
      mockReadService = mock(CategoryReadService);
      mockWriteService = mock(CategoryWriteService);
      service = new CategoryStateService(
        instance(mockReadService),
        instance(mockWriteService)
      );
    });

    it('should load categories', async () => {
      const categories = [CategoryMother.create()];
      when(mockReadService.findAll()).thenResolve(categories);

      await service.loadCategories();

      expect(service.categories.value).toEqual(categories);
      verify(mockReadService.findAll()).once();
    });
  });
});
