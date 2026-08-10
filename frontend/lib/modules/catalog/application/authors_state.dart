import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class AuthorsState {
  const AuthorsState();
}

class AuthorsLoading extends AuthorsState {
  const AuthorsLoading();
}

class AuthorsLoaded extends AuthorsState {
  const AuthorsLoaded(this.authors, this.items, {this.selectedLetter, this.selectedAuthor});

  final List<String> authors;
  final List<ItemReadModel> items;
  final String? selectedLetter;
  final String? selectedAuthor;

  List<ItemReadModel> get selectedItems {
    final author = selectedAuthor;
    if (author == null) return const [];
    return items.where((item) => item.creator.contains(author)).toList();
  }
}

class AuthorsError extends AuthorsState {
  const AuthorsError(this.message);

  final String message;
}
