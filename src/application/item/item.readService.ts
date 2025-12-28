import { injectable, inject } from 'inversify';
import { Item } from '../../domain/model/entities/Item';
import { Id } from '../../domain/model/value-objects/Id';
import { ItemsRepository } from '../../domain/repositories/ItemsRepository';

@injectable()
export class ItemReadService {
  constructor(@inject(ItemsRepository) private repository: ItemsRepository) {}

  async findAll(ownerId?: Id): Promise<Item[]> {
    return this.repository.findAll(ownerId);
  }

  async findById(id: Id): Promise<Item | undefined> {
    return this.repository.findById(id);
  }

  async search(query: string): Promise<Item[]> {
    return this.repository.search(query);
  }
}
