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

  async search(query: string): Promise<Item[]> {
    const lowerQuery = query.toLowerCase();
    return Array.from(this.items.values()).filter(item =>
      item.title.value.toLowerCase().includes(lowerQuery) ||
      item.author.value.toLowerCase().includes(lowerQuery) ||
      item.description.value.toLowerCase().includes(lowerQuery) ||
      item.publisher.value.toLowerCase().includes(lowerQuery) ||
      item.owner.value.toLowerCase().includes(lowerQuery) ||
      item.topic.value.toLowerCase().includes(lowerQuery) ||
      item.format.value.toLowerCase().includes(lowerQuery) ||
      item.language.value.toLowerCase().includes(lowerQuery) ||
      item.tags.value.some(tag => tag.toLowerCase().includes(lowerQuery)) ||
      item.category.name.value.toLowerCase().includes(lowerQuery)
    );
  }
}
