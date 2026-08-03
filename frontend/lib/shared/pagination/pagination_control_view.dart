import 'package:flutter/material.dart';

class PaginationControlView extends StatelessWidget {
  const PaginationControlView({
    required this.page,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final int page;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: hasPreviousPage ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous page',
        ),
        Text('Page $page of $totalPages'),
        IconButton(
          onPressed: hasNextPage ? onNext : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next page',
        ),
      ],
    );
  }
}
