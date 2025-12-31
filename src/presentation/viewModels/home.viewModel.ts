import { computed } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';

export class HomeViewModel {
  constructor(private itemStateService: ItemStateService) {}

  loadItems() {
    this.itemStateService.loadItems();
  }

  get items() {
    return this.itemStateService.items;
  }

  get isLoading() {
    return this.itemStateService.isLoading;
  }

  recentItems = computed(() => {
    return [...this.items.value]
      .sort((a, b) => b.created.value.getTime() - a.created.value.getTime())
      .slice(0, 5);
  });
}
