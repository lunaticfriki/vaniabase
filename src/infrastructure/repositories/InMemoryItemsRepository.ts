import { injectable } from 'inversify';
import { Item } from '../../domain/model/entities/Item';
import { Id } from '../../domain/model/value-objects/Id';
import { ItemsRepository } from '../../domain/repositories/ItemsRepository';
import { ItemSeed } from '../../domain/seed/ItemSeed';

@injectable()
export class InMemoryItemsRepository implements ItemsRepository {
  private items: Map<string, Item> = new Map();

  constructor() {
    console.log('[InMemoryItemsRepository] Initializing...');
    const seedItems = ItemSeed.generate();
    console.log(`[InMemoryItemsRepository] Seeded with ${seedItems.length} items.`);
    seedItems.forEach(item => {
      this.items.set(item.id.value, item);
    });
    console.log(`[InMemoryItemsRepository] Repository size: ${this.items.size}`);
  }

  async save(item: Item): Promise<void> {
    this.items.set(item.id.value, item);
  }

  async findAll(): Promise<Item[]> {
    return Array.from(this.items.values());
  }

  async findById(id: Id): Promise<Item | undefined> {
    return this.items.get(id.value);
  }
}
