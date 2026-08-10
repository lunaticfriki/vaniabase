import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/publishers_state.dart';

class PublishersStateService extends Cubit<PublishersState> {
  PublishersStateService(this._readService, {String? initialPublisher})
    : _initialPublisher = initialPublisher,
      super(const PublishersLoading()) {
    _subscription = _readService.watchAll().listen(
      _onItems,
      onError: (Object error) => emit(PublishersError(error.toString())),
    );
  }

  final ItemReadService _readService;
  final String? _initialPublisher;
  late final StreamSubscription<List<ItemReadModel>> _subscription;

  void _onItems(List<ItemReadModel> items) {
    final publishers =
        items.map((item) => item.publisher).where((publisher) => publisher.isNotEmpty).toSet().toList()
          ..sort();

    final current = state;
    String? selectedLetter;
    String? selectedPublisher;
    if (current is PublishersLoaded && current.selectedLetter != null) {
      final entriesForLetter = publishers.where(
        (publisher) => letterForEntry(publisher) == current.selectedLetter,
      );
      if (entriesForLetter.isNotEmpty) {
        selectedLetter = current.selectedLetter;
        selectedPublisher = entriesForLetter.contains(current.selectedPublisher)
            ? current.selectedPublisher
            : entriesForLetter.first;
      }
    } else if (current is! PublishersLoaded) {
      final initialPublisher = _initialPublisher;
      selectedLetter = initialPublisher == null ? null : letterForEntry(initialPublisher);
      selectedPublisher = initialPublisher;
    }

    emit(
      PublishersLoaded(
        publishers,
        items,
        selectedLetter: selectedLetter,
        selectedPublisher: selectedPublisher,
      ),
    );
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

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
