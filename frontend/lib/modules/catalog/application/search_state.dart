import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class SearchState {
  const SearchState();
}

class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchInProgress extends SearchState {
  const SearchInProgress();
}

class SearchLoaded extends SearchState {
  const SearchLoaded(this.query, this.items);

  final String query;
  final List<ItemReadModel> items;
}

class SearchError extends SearchState {
  const SearchError(this.message);

  final String message;
}
