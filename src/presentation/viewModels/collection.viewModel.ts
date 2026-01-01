
import { signal, computed } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';

export class CollectionViewModel {
  public currentPage = signal(1);
  public itemsPerPage = 20;

  constructor(private itemStateService: ItemStateService) {
    this.itemStateService.loadItems();
  }

  public allItems = computed(() => {
    return [...this.itemStateService.items.value].sort((a, b) => {
      const yearDiff = b.year.value - a.year.value;
      if (yearDiff !== 0) return yearDiff;
      return b.id.value.localeCompare(a.id.value);
    });
  });

  public filteredItems = computed(() => {
    return this.allItems.value;
  });

  public totalItems = computed(() => this.filteredItems.value.length);
  
  public totalPages = computed(() => Math.ceil(this.totalItems.value / this.itemsPerPage));

  public paginatedItems = computed(() => {
    const start = (this.currentPage.value - 1) * this.itemsPerPage;
    const end = start + this.itemsPerPage;
    return this.filteredItems.value.slice(start, end);
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
