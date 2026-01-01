import { signal, computed, effect } from '@preact/signals';
import { ItemStateService } from '../../application/item/item.stateService';
import { FormatStatistics } from '../../domain/model/formatStatistics.model';
import { PaginationViewModel } from './pagination.viewModel';

export class FormatsViewModel {
  private itemStateService: ItemStateService;

  activeFormatName = signal<string>('');
  pagination: PaginationViewModel;

  constructor(itemStateService: ItemStateService) {
    this.itemStateService = itemStateService;
    this.pagination = new PaginationViewModel(12);

    effect(() => {
      void this.activeFormatName.value;
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

  formatData = computed(() => {
    return FormatStatistics.fromItems(this.items.value);
  });

  filteredItems = computed(() => {
    const items = this.items.value;
    if (!items.length) return [];

    const active = this.activeFormatName.value.toLowerCase();
    if (!active) return items;

    return items.filter(item => item.format.value.toLowerCase() === active);
  });

  currentItems = computed(() => {
    const start = (this.pagination.currentPage.value - 1) * this.pagination.itemsPerPage;
    const end = start + this.pagination.itemsPerPage;
    return this.filteredItems.value.slice(start, end);
  });

  setFormat(formatName: string | undefined) {
    this.activeFormatName.value = (formatName || '').toLowerCase();
  }

  getFontSizeClass(count: number): string {
    const { minCount, maxCount } = this.formatData.value;

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
