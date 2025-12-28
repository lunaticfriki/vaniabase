import { Item } from '../model/entities/Item';
import { Id } from '../model/value-objects/Id';

export abstract class ItemsRepository {
  abstract save(item: Item): Promise<void>;
  abstract findAll(ownerId?: Id): Promise<Item[]>;
  abstract findById(id: Id): Promise<Item | undefined>;
  abstract search(query: string): Promise<Item[]>;
}
