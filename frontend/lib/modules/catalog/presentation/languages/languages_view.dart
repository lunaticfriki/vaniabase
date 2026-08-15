import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/languages_state_service.dart';
import 'package:frontend/modules/catalog/presentation/alphabet_index_view.dart';
import 'package:frontend/shared/layout/app_footer_view.dart';

class LanguagesView extends StatelessWidget {
  const LanguagesView({
    required this.state,
    required this.onLetterTap,
    required this.onLanguageTap,
    required this.onItemTap,
    this.onExport,
    super.key,
  });

  final LanguagesState state;
  final void Function(String letter) onLetterTap;
  final void Function(String language) onLanguageTap;
  final void Function(ItemReadModel item) onItemTap;
  final void Function(List<ItemReadModel> items, String language)? onExport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Languages', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Expanded(
            child: _LanguagesBody(
              state: state,
              onLetterTap: onLetterTap,
              onLanguageTap: onLanguageTap,
              onItemTap: onItemTap,
              onExport: onExport,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagesBody extends StatelessWidget {
  const _LanguagesBody({
    required this.state,
    required this.onLetterTap,
    required this.onLanguageTap,
    required this.onItemTap,
    this.onExport,
  });

  final LanguagesState state;
  final void Function(String letter) onLetterTap;
  final void Function(String language) onLanguageTap;
  final void Function(ItemReadModel item) onItemTap;
  final void Function(List<ItemReadModel> items, String language)? onExport;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      LanguagesLoading() => const Center(child: CircularProgressIndicator()),
      LanguagesError(:final message) => Center(child: Text(message)),
      LanguagesLoaded(:final languages) when languages.isEmpty => const Center(
        child: Text('No languages yet.'),
      ),
      LanguagesLoaded(
        :final languages,
        :final selectedLetter,
        :final selectedLanguage,
        :final selectedItems,
      ) =>
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AlphabetIndexView(
                entries: languages,
                selectedLetter: selectedLetter,
                selectedEntry: selectedLanguage,
                selectedItems: selectedItems,
                onLetterTap: onLetterTap,
                onEntryTap: onLanguageTap,
                onItemTap: onItemTap,
                entryNoun: 'language',
                onExport: onExport,
              ),
              const SizedBox(height: 24),
              const AppFooterView(),
            ],
          ),
        ),
    };
  }
}
