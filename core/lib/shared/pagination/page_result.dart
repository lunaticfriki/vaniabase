class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
  });

  factory PageResult.empty({int pageSize = 10}) => PageResult<T>(
        items: const [],
        page: 1,
        pageSize: pageSize,
        totalItems: 0,
      );

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalItems;

  int get totalPages => totalItems == 0 ? 0 : (totalItems / pageSize).ceil();

  bool get hasNextPage => page < totalPages;

  bool get hasPreviousPage => page > 1;

  PageResult<R> map<R>(R Function(T item) transform) {
    return PageResult<R>(
      items: items.map(transform).toList(),
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
    );
  }
}
