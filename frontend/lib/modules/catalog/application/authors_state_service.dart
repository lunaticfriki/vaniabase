import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/authors_state.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

class AuthorsStateService extends Cubit<AuthorsState> {
  AuthorsStateService(this._readService, {String? initialAuthor})
    : _initialAuthor = initialAuthor,
      super(const AuthorsLoading()) {
    _subscription = _readService.watchAll().listen(
      _onItems,
      onError: (Object error) => emit(AuthorsError(error.toString())),
    );
  }

  final ItemReadService _readService;
  final String? _initialAuthor;
  late final StreamSubscription<List<ItemReadModel>> _subscription;

  void _onItems(List<ItemReadModel> items) {
    final authors =
        items.expand((item) => item.creator).where((author) => author.isNotEmpty).toSet().toList()
          ..sort();

    final current = state;
    String? selectedLetter;
    String? selectedAuthor;
    if (current is AuthorsLoaded && current.selectedLetter != null) {
      final entriesForLetter = authors.where((author) => letterForEntry(author) == current.selectedLetter);
      if (entriesForLetter.isNotEmpty) {
        selectedLetter = current.selectedLetter;
        selectedAuthor = entriesForLetter.contains(current.selectedAuthor)
            ? current.selectedAuthor
            : entriesForLetter.first;
      }
    } else if (current is! AuthorsLoaded) {
      final initialAuthor = _initialAuthor;
      selectedLetter = initialAuthor == null ? null : letterForEntry(initialAuthor);
      selectedAuthor = initialAuthor;
    }

    emit(AuthorsLoaded(authors, items, selectedLetter: selectedLetter, selectedAuthor: selectedAuthor));
  }

  void selectLetter(String letter) {
    final current = state;
    if (current is! AuthorsLoaded) return;
    if (current.selectedLetter == letter) {
      emit(AuthorsLoaded(current.authors, current.items));
      return;
    }
    final authorsForLetter = current.authors.where((author) => letterForEntry(author) == letter);
    emit(
      AuthorsLoaded(
        current.authors,
        current.items,
        selectedLetter: letter,
        selectedAuthor: authorsForLetter.isEmpty ? null : authorsForLetter.first,
      ),
    );
  }

  void selectAuthor(String author) {
    final current = state;
    if (current is! AuthorsLoaded) return;
    emit(
      AuthorsLoaded(
        current.authors,
        current.items,
        selectedLetter: current.selectedLetter,
        selectedAuthor: current.selectedAuthor == author ? null : author,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
