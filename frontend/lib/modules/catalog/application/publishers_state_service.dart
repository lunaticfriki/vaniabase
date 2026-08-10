import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/fetch_all_items_util.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/publishers_state.dart';

class PublishersStateService extends Cubit<PublishersState> {
  PublishersStateService(this._readService, {String? initialPublisher})
    : _initialPublisher = initialPublisher,
      super(const PublishersLoading()) {
    _load();
  }

  final ItemReadService _readService;
  final String? _initialPublisher;

  Future<void> _load() async {
    try {
      final items = await fetchAllItems(_readService);
      final publishers =
          items.map((item) => item.publisher).where((publisher) => publisher.isNotEmpty).toSet().toList()
            ..sort();
      final initialPublisher = _initialPublisher;
      emit(
        PublishersLoaded(
          publishers,
          items,
          selectedLetter: initialPublisher == null ? null : letterForEntry(initialPublisher),
          selectedPublisher: initialPublisher,
        ),
      );
    } catch (error) {
      emit(PublishersError(error.toString()));
    }
  }

  void selectLetter(String letter) {
    final current = state;
    if (current is! PublishersLoaded) return;
    if (current.selectedLetter == letter) {
      emit(PublishersLoaded(current.publishers, current.items));
      return;
    }
    final publishersForLetter = current.publishers.where(
      (publisher) => letterForEntry(publisher) == letter,
    );
    emit(
      PublishersLoaded(
        current.publishers,
        current.items,
        selectedLetter: letter,
        selectedPublisher: publishersForLetter.isEmpty ? null : publishersForLetter.first,
      ),
    );
  }

  void selectPublisher(String publisher) {
    final current = state;
    if (current is! PublishersLoaded) return;
    emit(
      PublishersLoaded(
        current.publishers,
        current.items,
        selectedLetter: current.selectedLetter,
        selectedPublisher: current.selectedPublisher == publisher ? null : publisher,
      ),
    );
  }
}
