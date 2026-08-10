import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/categories_state.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

const categoryPreviewCount = 8;

class CategoriesStateService extends Cubit<CategoriesState> {
  CategoriesStateService(this._readService, this._categories) : super(const CategoriesLoading()) {
    _previewImageUrls = {for (final category in _categories) category: const <String>[]};
    _subscriptions = [
      for (final category in _categories)
        _readService
            .watchAll(category: category)
            .listen(
              (items) => _onCategoryItems(category, items),
              onError: (Object error) => emit(CategoriesError(error.toString())),
            ),
    ];
  }

  final ItemReadService _readService;
  final List<String> _categories;
  late Map<String, List<String>> _previewImageUrls;
  late final List<StreamSubscription<List<ItemReadModel>>> _subscriptions;

  void _onCategoryItems(String category, List<ItemReadModel> items) {
    _previewImageUrls = Map.of(_previewImageUrls)
      ..[category] = items.take(categoryPreviewCount).map((item) => item.imageUrl).toList();
    emit(CategoriesLoaded(_previewImageUrls));
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
