import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/tags_state_service.dart';
import 'package:frontend/modules/catalog/presentation/paginated_item_grid_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';

const _minTagFontSize = 14.0;
const _maxTagFontSize = 34.0;

class TagsView extends StatelessWidget {
  const TagsView({
    required this.state,
    required this.onTagTap,
    required this.onItemTap,
    super.key,
  });

  final TagsState state;
  final void Function(String tag) onTagTap;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tags', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: _TagsBody(
              state: state,
              onTagTap: onTagTap,
              onItemTap: onItemTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagsBody extends StatefulWidget {
  const _TagsBody({
    required this.state,
    required this.onTagTap,
    required this.onItemTap,
  });

  final TagsState state;
  final void Function(String tag) onTagTap;
  final void Function(ItemReadModel item) onItemTap;

  @override
  State<_TagsBody> createState() => _TagsBodyState();
}

class _TagsBodyState extends State<_TagsBody> {
  final _resultsKey = GlobalKey();

  String? _selectedTagOf(TagsState state) =>
      state is TagsLoaded ? state.selectedTag : null;

  @override
  void didUpdateWidget(covariant _TagsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedTag = _selectedTagOf(widget.state);
    if (selectedTag != null && selectedTag != _selectedTagOf(oldWidget.state)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final resultsContext = _resultsKey.currentContext;
        if (resultsContext != null) {
          Scrollable.ensureVisible(
            resultsContext,
            alignment: 0.1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.state) {
      TagsLoading() => const Center(child: CircularProgressIndicator()),
      TagsError(:final message) => Center(child: Text(message)),
      TagsLoaded(:final tagCounts) when tagCounts.isEmpty => const Center(
        child: Text('No tags yet.'),
      ),
      TagsLoaded(:final tagCounts, :final selectedTag, :final selectedItems) =>
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TagCloud(
                tagCounts: tagCounts,
                selectedTag: selectedTag,
                onTagTap: widget.onTagTap,
              ),
              if (selectedTag != null) ...[
                const SizedBox(height: 24),
                Text(
                  key: _resultsKey,
                  '"$selectedTag" — ${selectedItems.length} item${selectedItems.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                selectedItems.isEmpty
                    ? const Text('No items with this tag.')
                    : PaginatedItemGridView(
                        key: ValueKey(selectedTag),
                        items: selectedItems,
                        onItemTap: widget.onItemTap,
                      ),
              ],
              const SizedBox(height: 24),
              const AppFooterView(),
            ],
          ),
        ),
    };
  }
}

class _TagCloud extends StatelessWidget {
  const _TagCloud({
    required this.tagCounts,
    required this.selectedTag,
    required this.onTagTap,
  });

  final List<TagCount> tagCounts;
  final String? selectedTag;
  final void Function(String tag) onTagTap;

  @override
  Widget build(BuildContext context) {
    final counts = tagCounts.map((tagCount) => tagCount.count);
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final minCount = counts.reduce((a, b) => a < b ? a : b);
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final tagCount in tagCounts)
          InkWell(
            onTap: () => onTagTap(tagCount.tag),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                tagCount.tag,
                style: TextStyle(
                  fontSize: _fontSizeFor(tagCount.count, minCount, maxCount),
                  fontWeight: tagCount.tag == selectedTag
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: tagCount.tag == selectedTag
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _fontSizeFor(int count, int minCount, int maxCount) {
    if (maxCount == minCount) return (_minTagFontSize + _maxTagFontSize) / 2;
    final ratio = (count - minCount) / (maxCount - minCount);
    return _minTagFontSize + ratio * (_maxTagFontSize - _minTagFontSize);
  }
}
