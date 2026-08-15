import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/paginated_item_grid_view.dart';
import 'package:pixelarticons/pixel.dart';

class AlphabetIndexView extends StatefulWidget {
  const AlphabetIndexView({
    required this.entries,
    required this.selectedLetter,
    required this.selectedEntry,
    required this.selectedItems,
    required this.onLetterTap,
    required this.onEntryTap,
    required this.onItemTap,
    required this.entryNoun,
    this.onExport,
    super.key,
  });

  final List<String> entries;
  final String? selectedLetter;
  final String? selectedEntry;
  final List<ItemReadModel> selectedItems;
  final void Function(String letter) onLetterTap;
  final void Function(String entry) onEntryTap;
  final void Function(ItemReadModel item) onItemTap;
  final void Function(List<ItemReadModel> items, String entry)? onExport;

  /// Singular noun describing an entry (e.g. "topic", "author"), used in hint copy.
  final String entryNoun;

  @override
  State<AlphabetIndexView> createState() => _AlphabetIndexViewState();
}

class _AlphabetIndexViewState extends State<AlphabetIndexView> {
  final _resultsKey = GlobalKey();

  @override
  void didUpdateWidget(covariant AlphabetIndexView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedEntry != null &&
        widget.selectedEntry != oldWidget.selectedEntry) {
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
    final grouped = <String, List<String>>{};
    for (final entry in widget.entries) {
      grouped.putIfAbsent(letterForEntry(entry), () => []).add(entry);
    }
    for (final group in grouped.values) {
      group.sort();
    }
    final letters = [...alphabetLetters, if (grouped.containsKey('#')) '#'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AlphabetStrip(
          letters: letters,
          availableLetters: grouped.keys.toSet(),
          selectedLetter: widget.selectedLetter,
          onLetterTap: widget.onLetterTap,
        ),
        const SizedBox(height: 16),
        if (widget.selectedLetter == null)
          Text(
            'Tap a letter above to see ${widget.entryNoun}s starting with it.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          _EntryRow(
            entries: grouped[widget.selectedLetter] ?? const [],
            selectedEntry: widget.selectedEntry,
            onEntryTap: widget.onEntryTap,
          ),
        if (widget.selectedEntry != null) ...[
          const SizedBox(height: 24),
          Row(
            key: _resultsKey,
            children: [
              Expanded(
                child: Text(
                  '"${widget.selectedEntry}" — ${widget.selectedItems.length} item${widget.selectedItems.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (widget.onExport != null)
                IconButton(
                  tooltip: 'Export',
                  icon: const Icon(Pixel.download),
                  onPressed: () => widget.onExport!(
                    widget.selectedItems,
                    widget.selectedEntry!,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          widget.selectedItems.isEmpty
              ? Text('No items for this ${widget.entryNoun}.')
              : PaginatedItemGridView(
                  key: ValueKey(widget.selectedEntry),
                  items: widget.selectedItems,
                  onItemTap: widget.onItemTap,
                ),
        ],
      ],
    );
  }
}

class _AlphabetStrip extends StatelessWidget {
  const _AlphabetStrip({
    required this.letters,
    required this.availableLetters,
    required this.selectedLetter,
    required this.onLetterTap,
  });

  final List<String> letters;
  final Set<String> availableLetters;
  final String? selectedLetter;
  final void Function(String letter) onLetterTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final letter in letters)
          _LetterButton(
            letter: letter,
            enabled: availableLetters.contains(letter),
            selected: letter == selectedLetter,
            onTap: () => onLetterTap(letter),
          ),
      ],
    );
  }
}

class _LetterButton extends StatelessWidget {
  const _LetterButton({
    required this.letter,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          letter,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected
                ? colorScheme.onPrimary
                : enabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entries,
    required this.selectedEntry,
    required this.onEntryTap,
  });

  final List<String> entries;
  final String? selectedEntry;
  final void Function(String entry) onEntryTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in entries)
          InkWell(
            onTap: () => onEntryTap(entry),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: entry == selectedEntry
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                entry,
                style: TextStyle(
                  color: entry == selectedEntry
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
