import 'dart:async';

import 'package:core/modules/catalog/domain/search/search_term.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/fetch_all_items_util.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/search_state.dart';

const searchDebounce = Duration(milliseconds: 300);

class SearchStateService extends Cubit<SearchState> {
  SearchStateService(this._readService) : super(const SearchIdle());

  final ItemReadService _readService;
  Timer? _debounce;

  void onQueryChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(const SearchIdle());
      return;
    }
    _debounce = Timer(searchDebounce, () => _search(trimmed));
  }

  Future<void> _search(String query) async {
    emit(const SearchInProgress());
    try {
      final term = SearchTerm.create(query);
      final items = await fetchAllItems(_readService);
      final matches = items.where((item) => term.matchesAny(_searchableFields(item))).toList();
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
    return super.close();
  }
}
