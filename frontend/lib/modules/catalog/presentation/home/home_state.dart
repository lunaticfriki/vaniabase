import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class HomeState {
  const HomeState();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.items);

  final List<ItemReadModel> items;
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;
}
