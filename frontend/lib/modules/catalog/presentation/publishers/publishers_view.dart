import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/publishers_state.dart';
import 'package:frontend/modules/catalog/presentation/alphabet_index_view.dart';

class PublishersView extends StatelessWidget {
  const PublishersView({
    required this.state,
    required this.onLetterTap,
    required this.onPublisherTap,
    required this.onItemTap,
    super.key,
  });

  final PublishersState state;
  final void Function(String letter) onLetterTap;
  final void Function(String publisher) onPublisherTap;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Publishers', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: _PublishersBody(
              state: state,
              onLetterTap: onLetterTap,
              onPublisherTap: onPublisherTap,
              onItemTap: onItemTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishersBody extends StatelessWidget {
  const _PublishersBody({
    required this.state,
    required this.onLetterTap,
    required this.onPublisherTap,
    required this.onItemTap,
  });

  final PublishersState state;
  final void Function(String letter) onLetterTap;
  final void Function(String publisher) onPublisherTap;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PublishersLoading() => const Center(child: CircularProgressIndicator()),
      PublishersError(:final message) => Center(child: Text(message)),
      PublishersLoaded(:final publishers) when publishers.isEmpty => const Center(
        child: Text('No publishers yet.'),
      ),
      PublishersLoaded(
        :final publishers,
        :final selectedLetter,
        :final selectedPublisher,
        :final selectedItems,
      ) =>
        SingleChildScrollView(
          child: AlphabetIndexView(
            entries: publishers,
            selectedLetter: selectedLetter,
            selectedEntry: selectedPublisher,
            selectedItems: selectedItems,
            onLetterTap: onLetterTap,
            onEntryTap: onPublisherTap,
            onItemTap: onItemTap,
            entryNoun: 'publisher',
          ),
        ),
    };
  }
}
