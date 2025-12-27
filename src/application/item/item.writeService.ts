import { injectable, inject } from 'inversify';
import { Item } from '../../domain/model/entities/Item';
import { ItemsRepository } from '../../domain/repositories/ItemsRepository';
import { ErrorManager } from '../../domain/services/ErrorManager';
import { NotificationService } from '../../domain/services/NotificationService';

@injectable()
export class ItemWriteService {
  constructor(
    @inject(ItemsRepository) private repository: ItemsRepository,
    @inject(ErrorManager) private errorManager: ErrorManager,
    @inject(NotificationService) private notificationService: NotificationService
  ) {}

  async create(item: Item): Promise<void> {
    try {
      await this.repository.save(item);
      this.notificationService.notify('Item created successfully');
    } catch (error) {
      this.errorManager.handleError(error);
      throw error;
    }
  }

  async update(item: Item): Promise<void> {
    try {
      await this.repository.save(item);
      this.notificationService.notify('Item updated successfully');
    } catch (error) {
      this.errorManager.handleError(error);
      throw error;
    }
  }
}
