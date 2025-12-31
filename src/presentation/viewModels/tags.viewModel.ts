import { signal, computed, effect } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';
import { TagStatistics } from '../../domain/model/tagStatistics.model';
import { PaginationViewModel } from './pagination.viewModel';

export class TagsViewModel {
  private itemStateService: ItemStateService;

  activeTagName = signal<string>('');
  pagination: PaginationViewModel;

  constructor(itemStateService: ItemStateService) {
    this.itemStateService = itemStateService;
    this.pagination = new PaginationViewModel(12);

    effect(() => {
      this.activeTagName.value;
      this.pagination.goToPage(1);
    });

    effect(() => {
      this.pagination.setTotalItems(this.filteredItems.value.length);
    });
  }

  loadItems() {
    this.itemStateService.loadItems();
  }

  get items() {
    return this.itemStateService.items;
  }

  get isLoading() {
    return this.itemStateService.isLoading;
  }

  tagData = computed(() => {
    return TagStatistics.fromItems(this.items.value);
  });

  filteredItems = computed(() => {
    const items = this.items.value;
    if (!items.length) return [];

    const active = this.activeTagName.value.toLowerCase();
    if (!active) return items;

    return items.filter(item => item.tags.value.some(tag => tag.toLowerCase() === active));
  });

  currentItems = computed(() => {
    const start = (this.pagination.currentPage.value - 1) * this.pagination.itemsPerPage;
    const end = start + this.pagination.itemsPerPage;
    return this.filteredItems.value.slice(start, end);
  });

  setTag(tagName: string | undefined) {
    this.activeTagName.value = (tagName || '').toLowerCase();
  }

  getFontSizeClass(count: number): string {
    const { minCount, maxCount } = this.tagData.value;

    if (minCount === maxCount) return 'text-lg';

    const normalized = (count - minCount) / (maxCount - minCount);

    if (normalized < 0.1) return 'text-sm';
    if (normalized < 0.25) return 'text-base';
    if (normalized < 0.4) return 'text-lg';
    if (normalized < 0.6) return 'text-xl';
    if (normalized < 0.8) return 'text-2xl';
    return 'text-3xl font-black';
  }
}
