
import { signal, computed } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';

export class CategoriesViewModel {
  public currentPage = signal(1);
  public itemsPerPage = 20;
  
  public selectedCategory = signal<string | null>(null);

  constructor(private itemStateService: ItemStateService) {
      if (this.itemStateService.items.value.length === 0) {
        this.itemStateService.loadItems();
      }
  }

  public categories = computed(() => {
    const categoryCounts = new Map<string, number>();
    
    this.itemStateService.items.value.forEach(item => {
        const cat = item.category.name.value.toLowerCase();
        categoryCounts.set(cat, (categoryCounts.get(cat) || 0) + 1);
    });
    
    return Array.from(categoryCounts.entries())
        .map(([name, count]) => ({ name, count }))
        .sort((a, b) => b.count - a.count);
  });

  public filteredItems = computed(() => {
      let items = this.itemStateService.items.value;
      if (this.selectedCategory.value) {
          items = items.filter(i => i.category.name.value.toLowerCase() === this.selectedCategory.value?.toLowerCase());
      }
      return items.sort((a, b) => b.created.value.getTime() - a.created.value.getTime());
  });

  public totalItems = computed(() => this.filteredItems.value.length);
  public totalPages = computed(() => Math.ceil(this.totalItems.value / this.itemsPerPage));

  public paginatedItems = computed(() => {
    const start = (this.currentPage.value - 1) * this.itemsPerPage;
    const end = start + this.itemsPerPage;
    return this.filteredItems.value.slice(start, end);
  });
  
  public isLoading = computed(() => this.itemStateService.isLoading.value);

  public selectCategory(category: string | null) {
      this.selectedCategory.value = category;
      this.currentPage.value = 1;
  }
}
