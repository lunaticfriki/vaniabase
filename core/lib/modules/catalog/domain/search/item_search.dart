import 'package:core/modules/catalog/domain/entities/item.dart';
import 'package:core/modules/catalog/domain/search/search_term.dart';

class ItemSearch {
  static List<Item> filter(List<Item> items, SearchTerm term) {
    if (term.isEmpty) return items;
    return items.where((item) => item.matches(term)).toList();
  }
}
