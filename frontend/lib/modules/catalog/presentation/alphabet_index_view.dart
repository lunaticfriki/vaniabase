import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/item_card_view.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';

class AlphabetIndexView extends StatelessWidget {
  const AlphabetIndexView({
    required this.entries,
    required this.selectedLetter,
    required this.selectedEntry,
    required this.selectedItems,
    required this.onLetterTap,
    required this.onEntryTap,
    required this.onItemTap,
    required this.entryNoun,
    super.key,
  });

  final List<String> entries;
  final String? selectedLetter;
  final String? selectedEntry;
  final List<ItemReadModel> selectedItems;
  final void Function(String letter) onLetterTap;
  final void Function(String entry) onEntryTap;
  final void Function(ItemReadModel item) onItemTap;

  /// Singular noun describing an entry (e.g. "topic", "author"), used in hint copy.
  final String entryNoun;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<String>>{};
    for (final entry in entries) {
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
          selectedLetter: selectedLetter,
          onLetterTap: onLetterTap,
        ),
        const SizedBox(height: 16),
        if (selectedLetter == null)
          Text(
            'Tap a letter above to see ${entryNoun}s starting with it.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          _EntryRow(
            entries: grouped[selectedLetter] ?? const [],
            selectedEntry: selectedEntry,
            onEntryTap: onEntryTap,
          ),
        if (selectedEntry != null) ...[
          const SizedBox(height: 24),
          Text(
            '"$selectedEntry" — ${selectedItems.length} item${selectedItems.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          selectedItems.isEmpty
              ? Text('No items for this $entryNoun.')
              : ResponsiveItemGrid<ItemReadModel>(
                  items: selectedItems,
                  itemBuilder: (context, item) => ItemCardView(item: item, onTap: () => onItemTap(item)),
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
  const _EntryRow({required this.entries, required this.selectedEntry, required this.onEntryTap});

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
                color: entry == selectedEntry ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                entry,
                style: TextStyle(
                  color: entry == selectedEntry ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
