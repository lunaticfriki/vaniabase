import { injectable } from 'inversify';
import { Item } from '../../domain/model/entities/item.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import { ItemsRepository } from '../../domain/repositories/items.repository';
import { ItemSeed } from '../../domain/seed/item.seed';

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

  save(item: Item): Promise<void> {
    this.items.set(item.id.value, item);
    return Promise.resolve();
  }

  saveAll(items: Item[]): Promise<void> {
    items.forEach(item => {
      this.items.set(item.id.value, item);
    });
    return Promise.resolve();
  }

  findAll(ownerId?: string): Promise<Item[]> {
    const allItems = Array.from(this.items.values());
    if (ownerId) {
      return Promise.resolve(allItems.filter(item => item.owner.value === ownerId));
    }
    return Promise.resolve(allItems);
  }

  findById(id: Id): Promise<Item | undefined> {
    return Promise.resolve(this.items.get(id.value));
  }

  delete(id: Id): Promise<void> {
    this.items.delete(id.value);
    return Promise.resolve();
  }

  search(query: string): Promise<Item[]> {
    const lowerQuery = query.toLowerCase();
    return Promise.resolve(Array.from(this.items.values()).filter(
      item =>
        item.title.value.toLowerCase().includes(lowerQuery) ||
        item.author.value.toLowerCase().includes(lowerQuery) ||
        item.description.value.toLowerCase().includes(lowerQuery) ||
        item.publisher.value.toLowerCase().includes(lowerQuery) ||
        item.owner.value.toLowerCase().includes(lowerQuery) ||
        item.topic.value.toLowerCase().includes(lowerQuery) ||
        item.format.value.toLowerCase().includes(lowerQuery) ||
        item.language.value.toLowerCase().includes(lowerQuery) ||
        item.tags.value.some(tag => tag.toLowerCase().includes(lowerQuery)) ||
        item.category.name.value.toLowerCase().includes(lowerQuery) ||
        item.reference.value.toLowerCase().includes(lowerQuery)
    ));
  }
}
