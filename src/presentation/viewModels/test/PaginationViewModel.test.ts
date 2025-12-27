import { PaginationViewModel } from '../PaginationViewModel';

describe('PaginationViewModel', () => {
  let viewModel: PaginationViewModel;

  beforeEach(() => {
    viewModel = new PaginationViewModel(10);
  });

  it('should initialize with default values', () => {
    expect(viewModel.currentPage.value).toBe(1);
    expect(viewModel.itemsPerPage).toBe(10);
    expect(viewModel.totalItems.value).toBe(0);
  });

  it('should calculate total pages correctly', () => {
    viewModel.setTotalItems(25);
    expect(viewModel.totalPages.value).toBe(3);
    
    viewModel.setTotalItems(10);
    expect(viewModel.totalPages.value).toBe(1);
    
    viewModel.setTotalItems(0);
    expect(viewModel.totalPages.value).toBe(0);
  });

  it('should navigate to next page', () => {
    viewModel.setTotalItems(20);
    viewModel.nextPage();
    expect(viewModel.currentPage.value).toBe(2);
  });

  it('should not navigate past last page', () => {
    viewModel.setTotalItems(10); // 1 page
    viewModel.nextPage();
    expect(viewModel.currentPage.value).toBe(1);
  });

  it('should navigate to previous page', () => {
    viewModel.setTotalItems(20);
    viewModel.goToPage(2);
    viewModel.prevPage();
    expect(viewModel.currentPage.value).toBe(1);
  });

  it('should not navigate before first page', () => {
    viewModel.prevPage();
    expect(viewModel.currentPage.value).toBe(1);
  });

  it('should go to specific page', () => {
    viewModel.setTotalItems(30); // 3 pages
    viewModel.goToPage(3);
    expect(viewModel.currentPage.value).toBe(3);
  });

  it('should not go to invalid page', () => {
    viewModel.setTotalItems(30);
    viewModel.goToPage(4);
    expect(viewModel.currentPage.value).toBe(1);
    
    viewModel.goToPage(0);
    expect(viewModel.currentPage.value).toBe(1);
  });

  it('should reset pagination', () => {
    viewModel.setTotalItems(30);
    viewModel.goToPage(3);
    viewModel.reset();
    expect(viewModel.currentPage.value).toBe(1);
  });
});
