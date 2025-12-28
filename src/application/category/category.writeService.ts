import { injectable, inject } from 'inversify';
import { Category } from '../../domain/model/entities/category.entity';
import { CategoriesRepository } from '../../domain/repositories/categories.repository';
import { ErrorManager } from '../../domain/services/errorManager.service';
import { NotificationService } from '../../domain/services/notification.service';

@injectable()
export class CategoryWriteService {
  constructor(
    @inject(CategoriesRepository) private repository: CategoriesRepository,
    @inject(ErrorManager) private errorManager: ErrorManager,
    @inject(NotificationService) private notificationService: NotificationService
  ) {}

  async create(category: Category): Promise<void> {
    try {
      await this.repository.save(category);
      this.notificationService.notify('Category created successfully');
    } catch (error) {
      this.errorManager.handleError(error);
      throw error;
    }
  }

  async update(category: Category): Promise<void> {
    try {
      await this.repository.save(category);
      this.notificationService.notify('Category updated successfully');
    } catch (error) {
      this.errorManager.handleError(error);
      throw error;
    }
  }
}
