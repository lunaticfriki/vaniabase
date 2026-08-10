import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/topics_state.dart';
import 'package:frontend/modules/catalog/presentation/alphabet_index_view.dart';

class TopicsView extends StatelessWidget {
  const TopicsView({
    required this.state,
    required this.onLetterTap,
    required this.onTopicTap,
    required this.onItemTap,
    super.key,
  });

  final TopicsState state;
  final void Function(String letter) onLetterTap;
  final void Function(String topic) onTopicTap;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Topics', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: _TopicsBody(
              state: state,
              onLetterTap: onLetterTap,
              onTopicTap: onTopicTap,
              onItemTap: onItemTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicsBody extends StatelessWidget {
  const _TopicsBody({
    required this.state,
    required this.onLetterTap,
    required this.onTopicTap,
    required this.onItemTap,
  });

  final TopicsState state;
  final void Function(String letter) onLetterTap;
  final void Function(String topic) onTopicTap;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      TopicsLoading() => const Center(child: CircularProgressIndicator()),
      TopicsError(:final message) => Center(child: Text(message)),
      TopicsLoaded(:final topics) when topics.isEmpty => const Center(child: Text('No topics yet.')),
      TopicsLoaded(:final topics, :final selectedLetter, :final selectedTopic, :final selectedItems) =>
        SingleChildScrollView(
          child: AlphabetIndexView(
            entries: topics,
            selectedLetter: selectedLetter,
            selectedEntry: selectedTopic,
            selectedItems: selectedItems,
            onLetterTap: onLetterTap,
            onEntryTap: onTopicTap,
            onItemTap: onItemTap,
            entryNoun: 'topic',
          ),
        ),
    };
  }
}
