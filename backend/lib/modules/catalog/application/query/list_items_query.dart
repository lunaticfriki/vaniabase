class ListItemsQuery {
  const ListItemsQuery({
    required this.ownerId,
    this.page = 1,
    this.pageSize = 10,
  });

  final String ownerId;
  final int page;
  final int pageSize;
}
