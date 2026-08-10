import 'package:frontend/modules/catalog/application/item_read_model.dart';

sealed class LanguagesState {
  const LanguagesState();
}

class LanguagesLoading extends LanguagesState {
  const LanguagesLoading();
}

class LanguagesLoaded extends LanguagesState {
  const LanguagesLoaded(this.languages, this.items, {this.selectedLetter, this.selectedLanguage});

  final List<String> languages;
  final List<ItemReadModel> items;
  final String? selectedLetter;
  final String? selectedLanguage;

  List<ItemReadModel> get selectedItems {
    final language = selectedLanguage;
    if (language == null) return const [];
    return items.where((item) => item.language == language).toList();
  }
}

class LanguagesError extends LanguagesState {
  const LanguagesError(this.message);

  final String message;
}
