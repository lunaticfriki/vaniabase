import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/modules/catalog/application/home_state.dart';
import 'package:frontend/modules/catalog/application/item_read_model.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';

const homeItemCount = 10;

class HomeStateService extends Cubit<HomeState> {
  HomeStateService(this._readService) : super(const HomeLoading()) {
    _subscription = _readService.watchAll().listen(
      (items) => emit(HomeLoaded(items.take(homeItemCount).toList())),
      onError: (Object error) => emit(HomeError(error.toString())),
    );
  }

  final ItemReadService _readService;
  late final StreamSubscription<List<ItemReadModel>> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
