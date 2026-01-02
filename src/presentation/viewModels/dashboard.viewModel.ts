import { injectable, inject } from 'inversify';
import { signal, computed, Signal } from '@preact/signals';
import { ItemsRepository } from '../../domain/repositories/items.repository';
import { AuthService } from '../../application/auth/auth.service';
import { Item } from '../../domain/model/entities/item.entity';

@injectable()
export class DashboardViewModel {
  private _items: Signal<Item[]> = signal([]);
  private _isLoading: Signal<boolean> = signal(true);

  constructor(
    @inject('ItemsRepository') private itemsRepository: ItemsRepository,
    @inject(AuthService) private authService: AuthService
  ) {
    void this.loadData();
  }

  async loadData() {
    this._isLoading.value = true;
    try {
      const currentUser = this.authService.currentUser.value;
      if (currentUser) {
        this._items.value = await this.itemsRepository.findAll(currentUser.id.value);
      }
    } finally {
      this._isLoading.value = false;
    }
  }

  isLoading = computed(() => this._isLoading.value);
  currentUser = computed(() => this.authService.currentUser.value);

  totalItems = computed(() => this._items.value.length);

  categories = computed(() => {
    const counts = new Map<string, number>();
    this._items.value.forEach(item => {
      const name = item.category.name.value;
      counts.set(name, (counts.get(name) || 0) + 1);
    });

    return Array.from(counts.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
  });

  totalCategories = computed(() => this.categories.value.length);

  tags = computed(() => {
    const counts = new Map<string, number>();
    this._items.value.forEach(item => {
      item.tags.value.forEach(tag => {
        counts.set(tag, (counts.get(tag) || 0) + 1);
      });
    });

    return Array.from(counts.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
  });

  totalTags = computed(() => this.tags.value.length);

  topics = computed(() => {
    const counts = new Map<string, number>();
    this._items.value.forEach(item => {
      const topic = item.topic.value;
      if (topic) {
        counts.set(topic, (counts.get(topic) || 0) + 1);
      }
    });

    return Array.from(counts.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
  });

  totalTopics = computed(() => this.topics.value.length);

  formats = computed(() => {
    const counts = new Map<string, number>();
    this._items.value.forEach(item => {
      const format = item.format.value;
      if (format) {
        counts.set(format, (counts.get(format) || 0) + 1);
      }
    });

    return Array.from(counts.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => a.name.localeCompare(b.name));
  });

  totalFormats = computed(() => this.formats.value.length);

  completedItems = computed(() => {
    return this._items.value
      .filter(item => item.completed.value === true)
      .sort((a, b) => b.created.value.getTime() - a.created.value.getTime());
  });

  totalCompleted = computed(() => this.completedItems.value.length);
}
