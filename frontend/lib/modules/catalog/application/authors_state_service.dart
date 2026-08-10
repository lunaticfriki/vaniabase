import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/authors_state.dart';
import 'package:frontend/modules/catalog/application/fetch_all_items_util.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

class AuthorsStateService extends Cubit<AuthorsState> {
  AuthorsStateService(this._readService, {String? initialAuthor})
    : _initialAuthor = initialAuthor,
      super(const AuthorsLoading()) {
    _load();
  }

  final ItemReadService _readService;
  final String? _initialAuthor;

  Future<void> _load() async {
    try {
      final items = await fetchAllItems(_readService);
      final authors =
          items
              .expand((item) => item.creator)
              .where((author) => author.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      final initialAuthor = _initialAuthor;
      emit(
        AuthorsLoaded(
          authors,
          items,
          selectedLetter: initialAuthor == null ? null : letterForEntry(initialAuthor),
          selectedAuthor: initialAuthor,
        ),
      );
    } catch (error) {
      emit(AuthorsError(error.toString()));
    }
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
}
