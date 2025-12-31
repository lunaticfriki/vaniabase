import { injectable, inject } from 'inversify';
import { signal } from '@preact/signals';
import { Item } from '../../domain/model/entities/item.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import { ItemReadService } from './item.readService';
import { ItemWriteService } from './item.writeService';
import { AuthService } from '../auth/auth.service';
import { NotificationService } from '../../domain/services/notification.service';

@injectable()
export class ItemStateService {
  items = signal<Item[]>([]);
  isLoading = signal<boolean>(false);

  constructor(
    @inject(ItemReadService) private readService: ItemReadService,
    @inject(ItemWriteService) private writeService: ItemWriteService,
    @inject(AuthService) private authService: AuthService,
    @inject(NotificationService) private notificationService: NotificationService
  ) {}

  async loadItems(): Promise<void> {
    this.isLoading.value = true;
    try {
      console.log('[ItemStateService] Loading items...');
      const currentUser = this.authService.currentUser.value;
      const items = await this.readService.findAll(currentUser?.id);
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
      this.notificationService.success('Item created successfully');
    } finally {
      this.isLoading.value = false;
    }
  }

  async createItems(items: Item[]): Promise<void> {
    this.isLoading.value = true;
    try {
      await this.writeService.createAll(items);
      await this.loadItems();
      this.notificationService.success(`${items.length} items created successfully`);
    } finally {
      this.isLoading.value = false;
    }
  }

  async updateItem(item: Item): Promise<void> {
    this.isLoading.value = true;
    try {
      await this.writeService.update(item);
      await this.loadItems();
      this.notificationService.success('Item updated successfully');
    } finally {
      this.isLoading.value = false;
    }
  }

  async deleteItem(id: string): Promise<void> {
    this.isLoading.value = true;
    try {
      await this.writeService.delete(Id.create(id));
      await this.loadItems();
      this.notificationService.success('Item deleted successfully');
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
