import 'dart:async';

import 'package:core/modules/catalog/domain/search/search_term.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/search_state.dart';

const searchDebounce = Duration(milliseconds: 300);

class SearchStateService extends Cubit<SearchState> {
  SearchStateService(this._readService) : super(const SearchIdle()) {
    _subscription = _readService.watchAll().listen((items) {
      _items = items;
      final query = _currentQuery;
      if (query != null) _runSearch(query);
    });
  }

  final ItemReadService _readService;
  late final StreamSubscription<List<ItemReadModel>> _subscription;
  List<ItemReadModel> _items = const [];
  String? _currentQuery;
  Timer? _debounce;

  void onQueryChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _currentQuery = null;
      emit(const SearchIdle());
      return;
    }
    _debounce = Timer(searchDebounce, () => _runSearch(trimmed));
  }

  void _runSearch(String query) {
    _currentQuery = query;
    emit(const SearchInProgress());
    try {
      final term = SearchTerm.create(query);
      final matches = _items.where((item) => term.matchesAny(_searchableFields(item))).toList();
      emit(SearchLoaded(query, matches));
    } catch (error) {
      emit(SearchError(error.toString()));
    }
  }

  Iterable<String> _searchableFields(ItemReadModel item) => [
    item.title,
    ...item.creator,
    item.publisher,
    item.topic,
    item.reference,
    ...item.tags,
  ];

  @override
  Future<void> close() {
    _debounce?.cancel();
    _subscription.cancel();
    return super.close();
  }
}
