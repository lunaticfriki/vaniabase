import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

sealed class TopicsState {
  const TopicsState();
}

class TopicsLoading extends TopicsState {
  const TopicsLoading();
}

class TopicsLoaded extends TopicsState {
  const TopicsLoaded(
    this.topics,
    this.items, {
    this.selectedLetter,
    this.selectedTopic,
  });

  final List<String> topics;
  final List<ItemReadModel> items;
  final String? selectedLetter;
  final String? selectedTopic;

  List<ItemReadModel> get selectedItems {
    final topic = selectedTopic;
    if (topic == null) return const [];
    return items.where((item) => item.topic == topic).toList();
  }
}

class TopicsError extends TopicsState {
  const TopicsError(this.message);

  final String message;
}

class TopicsStateService extends Cubit<TopicsState> {
  TopicsStateService(this._readService, {String? initialTopic})
    : _initialTopic = initialTopic,
      super(const TopicsLoading()) {
    _subscription = _readService.watchAll().listen(
      _onItems,
      onError: (Object error) => emit(TopicsError(error.toString())),
    );
  }

  final ItemReadService _readService;
  final String? _initialTopic;
  late final StreamSubscription<List<ItemReadModel>> _subscription;

  void _onItems(List<ItemReadModel> items) {
    final topics =
        items
            .map((item) => item.topic)
            .where((topic) => topic.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final current = state;
    String? selectedLetter;
    String? selectedTopic;
    if (current is TopicsLoaded && current.selectedLetter != null) {
      final entriesForLetter = topics.where(
        (topic) => letterForEntry(topic) == current.selectedLetter,
      );
      if (entriesForLetter.isNotEmpty) {
        selectedLetter = current.selectedLetter;
        selectedTopic = entriesForLetter.contains(current.selectedTopic)
            ? current.selectedTopic
            : entriesForLetter.first;
      }
    } else if (current is! TopicsLoaded) {
      final initialTopic = _initialTopic;
      selectedLetter = initialTopic == null
          ? null
          : letterForEntry(initialTopic);
      selectedTopic = initialTopic;
    }

    emit(
      TopicsLoaded(
        topics,
        items,
        selectedLetter: selectedLetter,
        selectedTopic: selectedTopic,
      ),
    );
  }

  void selectLetter(String letter) {
    final current = state;
    if (current is! TopicsLoaded) return;
    if (current.selectedLetter == letter) {
      emit(TopicsLoaded(current.topics, current.items));
      return;
    }
    final topicsForLetter = current.topics.where(
      (topic) => letterForEntry(topic) == letter,
    );
    emit(
      TopicsLoaded(
        current.topics,
        current.items,
        selectedLetter: letter,
        selectedTopic: topicsForLetter.isEmpty ? null : topicsForLetter.first,
      ),
    );
  }

  void selectTopic(String topic) {
    final current = state;
    if (current is! TopicsLoaded) return;
    emit(
      TopicsLoaded(
        current.topics,
        current.items,
        selectedLetter: current.selectedLetter,
        selectedTopic: current.selectedTopic == topic ? null : topic,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
