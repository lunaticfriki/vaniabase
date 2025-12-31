import { signal, computed } from '@preact/signals';
import { Pagination } from '../../domain/pagination';

export class PaginationViewModel {
  currentPage = signal(1);
  itemsPerPage: number;
  totalItems = signal(0);

  constructor(itemsPerPage: number = 10) {
    this.itemsPerPage = itemsPerPage;
  }

  totalPages = computed(() => {
    return new Pagination(this.currentPage.value, this.itemsPerPage, this.totalItems.value).totalPages;
  });

  setTotalItems(count: number) {
    this.totalItems.value = count;
  }

  nextPage() {
    if (this.currentPage.value < this.totalPages.value) {
      this.currentPage.value++;
    }
  }

  prevPage() {
    if (this.currentPage.value > 1) {
      this.currentPage.value--;
    }
  }

  goToPage(page: number) {
    if (page >= 1 && page <= this.totalPages.value) {
      this.currentPage.value = page;
    }
  }

  reset() {
    this.currentPage.value = 1;
  }
}
