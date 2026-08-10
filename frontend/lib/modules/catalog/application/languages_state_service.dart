import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/fetch_all_items_util.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/languages_state.dart';

class LanguagesStateService extends Cubit<LanguagesState> {
  LanguagesStateService(this._readService, {String? initialLanguage})
    : _initialLanguage = initialLanguage,
      super(const LanguagesLoading()) {
    _load();
  }

  final ItemReadService _readService;
  final String? _initialLanguage;

  Future<void> _load() async {
    try {
      final items = await fetchAllItems(_readService);
      final languages =
          items.map((item) => item.language).where((language) => language.isNotEmpty).toSet().toList()
            ..sort();
      final initialLanguage = _initialLanguage;
      emit(
        LanguagesLoaded(
          languages,
          items,
          selectedLetter: initialLanguage == null ? null : letterForEntry(initialLanguage),
          selectedLanguage: initialLanguage,
        ),
      );
    } catch (error) {
      emit(LanguagesError(error.toString()));
    }
  }

  void selectLetter(String letter) {
    final current = state;
    if (current is! LanguagesLoaded) return;
    if (current.selectedLetter == letter) {
      emit(LanguagesLoaded(current.languages, current.items));
      return;
    }
    final languagesForLetter = current.languages.where((language) => letterForEntry(language) == letter);
    emit(
      LanguagesLoaded(
        current.languages,
        current.items,
        selectedLetter: letter,
        selectedLanguage: languagesForLetter.isEmpty ? null : languagesForLetter.first,
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
        selectedLanguage: current.selectedLanguage == language ? null : language,
      ),
    );
  }
}
