import 'package:core/shared/pagination/page_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/categories_state.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

const categoryPreviewCount = 8;

class CategoriesStateService extends Cubit<CategoriesState> {
  CategoriesStateService(this._readService, this._categories) : super(const CategoriesLoading()) {
    load();
  }

  final ItemReadService _readService;
  final List<String> _categories;

  Future<void> load() async {
    if (state is! CategoriesLoading) emit(const CategoriesLoading());
    try {
      final entries = await Future.wait(
        _categories.map((category) async {
          final result = await _readService.list(
            pageRequest: PageRequest.first(pageSize: categoryPreviewCount),
            category: category,
          );
          return MapEntry(category, result.items.map((item) => item.imageUrl).toList());
        }),
      );
      emit(CategoriesLoaded(Map.fromEntries(entries)));
    } catch (error) {
      emit(CategoriesError(error.toString()));
    }
  }
}
