import 'package:core/modules/catalog/domain/value_objects/category.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/pagination/page_request.dart';

class ItemCriteria {
  const ItemCriteria({required this.ownerId, required this.pageRequest, this.category});

  final UserId ownerId;
  final PageRequest pageRequest;
  final Category? category;

  @override
  bool operator ==(Object other) =>
      other is ItemCriteria &&
      other.ownerId == ownerId &&
      other.pageRequest == pageRequest &&
      other.category == category;

  @override
  int get hashCode => Object.hash(ownerId, pageRequest, category);
}
