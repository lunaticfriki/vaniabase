import { injectable, inject } from 'inversify';
import { signal } from '@preact/signals';
import { Item } from '../../domain/model/entities/Item';
import { ItemReadService } from './item.readService';
import { ItemWriteService } from './item.writeService';

@injectable()
export class ItemStateService {
  items = signal<Item[]>([]);
  isLoading = signal<boolean>(false);

  constructor(
    @inject(ItemReadService) private readService: ItemReadService,
    @inject(ItemWriteService) private writeService: ItemWriteService
  ) {}

  async loadItems(): Promise<void> {
    this.isLoading.value = true;
    try {
      console.log('[ItemStateService] Loading items...');
      const items = await this.readService.findAll();
      console.log(`[ItemStateService] Loaded ${items.length} items.`);
      this.items.value = items;
    } finally {
      this.isLoading.value = false;
    }
  }

  async createItem(item: Item): Promise<void> {
    this.isLoading.value = true;
    try {
      await this.writeService.create(item);
      await this.loadItems();
    } finally {
      this.isLoading.value = false;
    }
  }

  async updateItem(item: Item): Promise<void> {
    this.isLoading.value = true;
    try {
      await this.writeService.update(item);
      await this.loadItems();
    } finally {
      this.isLoading.value = false;
    }
  }

  async getItem(id: string): Promise<Item | undefined> {

    const existingIcon = this.items.value.find(i => i.id.value === id);
    if (existingIcon) {
      return existingIcon;
    }




    if (this.items.value.length === 0) {
      await this.loadItems();
      return this.items.value.find(i => i.id.value === id);
    }

    return undefined;
  }

  searchResults = signal<Item[]>([]);

  async searchItems(query: string): Promise<void> {
    this.isLoading.value = true;
    try {
      const results = await this.readService.search(query);
      this.searchResults.value = results;
    } finally {
      this.isLoading.value = false;
    }
  }
}
