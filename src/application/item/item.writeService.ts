import { injectable, inject } from 'inversify';
import { Item } from '../../domain/model/entities/item.entity';
import { ItemsRepository } from '../../domain/repositories/items.repository';
import { ErrorManager } from '../../domain/services/errorManager.service';
import { NotificationService } from '../../domain/services/notification.service';

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
