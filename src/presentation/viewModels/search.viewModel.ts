
import { signal } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';
import { Item } from '../../domain/model/entities/item.entity';

export class SearchViewModel {
  public query = signal('');
  public items = signal<Item[]>([]);
  public loading = signal(false);

  constructor(private itemStateService: ItemStateService) {}

  async search(query: string) {
    this.query.value = query;
    if (query.trim()) {
      this.loading.value = true;
      await this.itemStateService.searchItems(query);
      this.items.value = this.itemStateService.searchResults.value;
      this.loading.value = false;
    } else {
      this.items.value = [];
    }
  }
}
