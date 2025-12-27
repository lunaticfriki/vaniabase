export class Pagination {
  constructor(
    public readonly currentPage: number,
    public readonly itemsPerPage: number,
    public readonly totalItems: number
  ) {}

  get totalPages(): number {
    return Math.ceil(this.totalItems / this.itemsPerPage);
  }
}
