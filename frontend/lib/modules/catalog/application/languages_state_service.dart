import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

sealed class LanguagesState {
  const LanguagesState();
}

class LanguagesLoading extends LanguagesState {
  const LanguagesLoading();
}

class LanguagesLoaded extends LanguagesState {
  const LanguagesLoaded(
    this.languages,
    this.items, {
    this.selectedLetter,
    this.selectedLanguage,
  });

  final List<String> languages;
  final List<ItemReadModel> items;
  final String? selectedLetter;
  final String? selectedLanguage;

  List<ItemReadModel> get selectedItems {
    final language = selectedLanguage;
    if (language == null) return const [];
    return items.where((item) => item.language == language).toList();
  }
}

class LanguagesError extends LanguagesState {
  const LanguagesError(this.message);

  final String message;
}

class LanguagesStateService extends Cubit<LanguagesState> {
  LanguagesStateService(this._readService, {String? initialLanguage})
    : _initialLanguage = initialLanguage,
      super(const LanguagesLoading()) {
    _subscription = _readService.watchAll().listen(
      _onItems,
      onError: (Object error) => emit(LanguagesError(error.toString())),
    );
  }

  final ItemReadService _readService;
  final String? _initialLanguage;
  late final StreamSubscription<List<ItemReadModel>> _subscription;

  void _onItems(List<ItemReadModel> items) {
    final languages =
        items
            .map((item) => item.language)
            .where((language) => language.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final current = state;
    String? selectedLetter;
    String? selectedLanguage;
    if (current is LanguagesLoaded && current.selectedLetter != null) {
      final entriesForLetter = languages.where(
        (language) => letterForEntry(language) == current.selectedLetter,
      );
      if (entriesForLetter.isNotEmpty) {
        selectedLetter = current.selectedLetter;
        selectedLanguage = entriesForLetter.contains(current.selectedLanguage)
            ? current.selectedLanguage
            : entriesForLetter.first;
      }
    } else if (current is! LanguagesLoaded) {
      final initialLanguage = _initialLanguage;
      selectedLetter = initialLanguage == null
          ? null
          : letterForEntry(initialLanguage);
      selectedLanguage = initialLanguage;
    }

    emit(
      LanguagesLoaded(
        languages,
        items,
        selectedLetter: selectedLetter,
        selectedLanguage: selectedLanguage,
      ),
    );
  }

  void selectLetter(String letter) {
    final current = state;
    if (current is! LanguagesLoaded) return;
    if (current.selectedLetter == letter) {
      emit(LanguagesLoaded(current.languages, current.items));
      return;
    }
    final languagesForLetter = current.languages.where(
      (language) => letterForEntry(language) == letter,
    );
    emit(
      LanguagesLoaded(
        current.languages,
        current.items,
        selectedLetter: letter,
        selectedLanguage: languagesForLetter.isEmpty
            ? null
            : languagesForLetter.first,
      ),
    );
  }

  void selectLanguage(String language) {
    final current = state;
    if (current is! LanguagesLoaded) return;
    emit(
      LanguagesLoaded(
        current.languages,
        current.items,
        selectedLetter: current.selectedLetter,
        selectedLanguage: current.selectedLanguage == language
            ? null
            : language,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
