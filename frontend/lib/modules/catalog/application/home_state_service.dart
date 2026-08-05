import 'package:core/shared/pagination/page_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/home_state.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

class HomeStateService extends Cubit<HomeState> {
  HomeStateService(this._readService) : super(const HomeLoading()) {
    load();
  }

  final ItemReadService _readService;

  Future<void> load() async {
    if (state is! HomeLoading) emit(const HomeLoading());
    try {
      final result = await _readService.list(
        pageRequest: PageRequest.first(pageSize: 10),
      );
      emit(HomeLoaded(result.items));
    } catch (error) {
      emit(HomeError(error.toString()));
    }
  }
}
