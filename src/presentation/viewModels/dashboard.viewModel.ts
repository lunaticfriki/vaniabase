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
    this.loadData();
  }

  async loadData() {
    this._isLoading.value = true;
    try {
      const currentUser = this.authService.currentUser.value;
      if (currentUser) {
        this._items.value = await this.itemsRepository.findAll();
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
      .sort((a, b) => a.name.localeCompare(b.name));
  });

  totalCategories = computed(() => this.categories.value.length);

  tags = computed(() => {
    const allTags = this._items.value.flatMap(i => i.tags.value);
    const uniqueTags = new Set(allTags);
    return Array.from(uniqueTags).sort();
  });

  totalTags = computed(() => this.tags.value.length);

  topics = computed(() => {
    const uniqueTopics = new Set(this._items.value.map(i => i.topic.value).filter(t => t));
    return Array.from(uniqueTopics).sort();
  });

  totalTopics = computed(() => this.topics.value.length);

  formats = computed(() => {
    const uniqueFormats = new Set(this._items.value.map(i => i.format.value).filter(f => f));
    return Array.from(uniqueFormats).sort();
  });

  totalFormats = computed(() => this.formats.value.length);
}
