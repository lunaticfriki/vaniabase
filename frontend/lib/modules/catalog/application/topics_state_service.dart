import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/alphabet_util.dart';
import 'package:frontend/modules/catalog/application/fetch_all_items_util.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/topics_state.dart';

class TopicsStateService extends Cubit<TopicsState> {
  TopicsStateService(this._readService, {String? initialTopic})
    : _initialTopic = initialTopic,
      super(const TopicsLoading()) {
    _load();
  }

  final ItemReadService _readService;
  final String? _initialTopic;

  Future<void> _load() async {
    try {
      final items = await fetchAllItems(_readService);
      final topics =
          items.map((item) => item.topic).where((topic) => topic.isNotEmpty).toSet().toList()..sort();
      final initialTopic = _initialTopic;
      emit(
        TopicsLoaded(
          topics,
          items,
          selectedLetter: initialTopic == null ? null : letterForEntry(initialTopic),
          selectedTopic: initialTopic,
        ),
      );
    } catch (error) {
      emit(TopicsError(error.toString()));
    }
  }

  void selectLetter(String letter) {
    final current = state;
    if (current is! TopicsLoaded) return;
    if (current.selectedLetter == letter) {
      emit(TopicsLoaded(current.topics, current.items));
      return;
    }
    final topicsForLetter = current.topics.where((topic) => letterForEntry(topic) == letter);
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
}
