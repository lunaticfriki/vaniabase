import { injectable, inject } from 'inversify';
import { Item } from '../../domain/model/entities/item.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import { ItemsRepository } from '../../domain/repositories/items.repository';
import { ErrorManager } from '../../domain/services/errorManager.service';

@injectable()
export class ItemWriteService {
  constructor(
    @inject(ItemsRepository) private repository: ItemsRepository,
    @inject(ErrorManager) private errorManager: ErrorManager
  ) {}

  async create(item: Item): Promise<void> {
    try {
      await this.repository.save(item);
    } catch (error) {
      this.errorManager.handleError(error);
      throw error;
    }
  }

  async createAll(items: Item[]): Promise<void> {
    try {
      await this.repository.saveAll(items);
    } catch (error) {
      this.errorManager.handleError(error);
      throw error;
    }
  }

  async update(item: Item): Promise<void> {
    try {
      await this.repository.save(item);
    } catch (error) {
      this.errorManager.handleError(error);
      throw error;
    }
  }

  async delete(id: Id): Promise<void> {
    try {
      await this.repository.delete(id);
    } catch (error) {
      this.errorManager.handleError(error);
    }
  }
}
