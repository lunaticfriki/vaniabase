import 'reflect-metadata';
import { mock, instance, when, verify, anyString, anything } from 'ts-mockito';
import { ItemStateService } from '../item/item.stateService';
import { ItemReadService } from '../item/item.readService';
import { ItemWriteService } from '../item/item.writeService';
import { CategoryStateService } from '../category/category.stateService';
import { CategoryReadService } from '../category/category.readService';
import { CategoryWriteService } from '../category/category.writeService';
import { ItemsRepository } from '../../domain/repositories/items.repository';
import { ErrorManager } from '../../domain/services/errorManager.service';
import { NotificationService } from '../../domain/services/notification.service';
import { AuthService } from '../auth/auth.service';
import { signal } from '@preact/signals';
import { ItemMother } from '../../domain/__tests__/item.mother';
import { CategoryMother } from '../../domain/__tests__/category.mother';

describe('Application Services (Unit Tests)', () => {
  describe('ItemReadService', () => {
    it('should find all items using repository', async () => {
      const mockRepo = mock<ItemsRepository>();
      const expectedItems = [ItemMother.create()];
      when(mockRepo.findAll(anything())).thenResolve(expectedItems);

      const service = new ItemReadService(instance(mockRepo));
      const items = await service.findAll();

      expect(items).toBe(expectedItems);
      verify(mockRepo.findAll(anything())).once();
    });
  });

  describe('ItemWriteService', () => {
    let mockRepo: ItemsRepository;
    let mockErrorManager: ErrorManager;
    let service: ItemWriteService;

    beforeEach(() => {
      mockRepo = mock<ItemsRepository>();
      mockErrorManager = mock<ErrorManager>();
      service = new ItemWriteService(
        instance(mockRepo),
        instance(mockErrorManager),
      );
    });

    it('should create item and notify success', async () => {
      const item = ItemMother.create();
      when(mockRepo.save(item)).thenResolve();

      await service.create(item);

      verify(mockRepo.save(item)).once();
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
    let mockAuthService: AuthService;
    let service: ItemStateService;
    let mockNotificationService: NotificationService;

    beforeEach(() => {
      mockReadService = mock(ItemReadService);
      mockWriteService = mock(ItemWriteService);
      mockAuthService = mock(AuthService);
      mockNotificationService = mock(NotificationService);
      service = new ItemStateService(
        instance(mockReadService),
        instance(mockWriteService),
        instance(mockAuthService),
        instance(mockNotificationService)
      );

      when(mockAuthService.currentUser).thenReturn(signal(null));
    });

    it('should load items and update signal', async () => {
      const items = [ItemMother.create()];
      when(mockReadService.findAll(anything())).thenResolve(items);

      await service.loadItems();

      expect(service.items.value).toEqual(items);
      verify(mockReadService.findAll(anything())).once();
    });

    it('should create item and reload', async () => {
      const item = ItemMother.create();
      when(mockWriteService.create(item)).thenResolve();
      when(mockReadService.findAll(anything())).thenResolve([item]);

      await service.createItem(item);

      verify(mockWriteService.create(item)).once();
      verify(mockReadService.findAll(anything())).once();
      verify(mockNotificationService.success(anyString())).once();
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
