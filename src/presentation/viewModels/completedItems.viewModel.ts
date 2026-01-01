
import { signal, computed } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';

export class CompletedItemsViewModel {
  public currentPage = signal(1);
  public itemsPerPage = 20;

  constructor(private itemStateService: ItemStateService) {
    this.itemStateService.loadItems();
  }

  public allCompletedItems = computed(() => {
    return this.itemStateService.items.value
      .filter(item => item.completed.value === true)
      .sort((a, b) => b.id.value.localeCompare(a.id.value));
  });

  public totalItems = computed(() => this.allCompletedItems.value.length);
  
  public totalPages = computed(() => Math.ceil(this.totalItems.value / this.itemsPerPage));

  public paginatedItems = computed(() => {
    const start = (this.currentPage.value - 1) * this.itemsPerPage;
    const end = start + this.itemsPerPage;
    return this.allCompletedItems.value.slice(start, end);
  });

  public isLoading = computed(() => this.itemStateService.isLoading.value);
  
  public setPage(page: number) {
    if (page < 1) page = 1;
    if (page > this.totalPages.value && this.totalPages.value > 0) page = this.totalPages.value;
    this.currentPage.value = page;
     if (typeof window !== 'undefined') {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  }
}
