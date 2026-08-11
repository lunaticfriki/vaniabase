import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/authors_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/presentation/alphabet_index_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';

class AuthorsView extends StatelessWidget {
  const AuthorsView({
    required this.state,
    required this.onLetterTap,
    required this.onAuthorTap,
    required this.onItemTap,
    super.key,
  });

  final AuthorsState state;
  final void Function(String letter) onLetterTap;
  final void Function(String author) onAuthorTap;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Authors', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: _AuthorsBody(
              state: state,
              onLetterTap: onLetterTap,
              onAuthorTap: onAuthorTap,
              onItemTap: onItemTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorsBody extends StatelessWidget {
  const _AuthorsBody({
    required this.state,
    required this.onLetterTap,
    required this.onAuthorTap,
    required this.onItemTap,
  });

  final AuthorsState state;
  final void Function(String letter) onLetterTap;
  final void Function(String author) onAuthorTap;
  final void Function(ItemReadModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AuthorsLoading() => const Center(child: CircularProgressIndicator()),
      AuthorsError(:final message) => Center(child: Text(message)),
      AuthorsLoaded(:final authors) when authors.isEmpty => const Center(
        child: Text('No authors yet.'),
      ),
      AuthorsLoaded(
        :final authors,
        :final selectedLetter,
        :final selectedAuthor,
        :final selectedItems,
      ) =>
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AlphabetIndexView(
                entries: authors,
                selectedLetter: selectedLetter,
                selectedEntry: selectedAuthor,
                selectedItems: selectedItems,
                onLetterTap: onLetterTap,
                onEntryTap: onAuthorTap,
                onItemTap: onItemTap,
                entryNoun: 'author',
              ),
              const SizedBox(height: 24),
              const AppFooterView(),
            ],
          ),
        ),
    };
  }
}
