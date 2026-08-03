import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/shared/pagination/page_request.dart';

class ItemCriteria {
  const ItemCriteria({required this.ownerId, required this.pageRequest});

  final UserId ownerId;
  final PageRequest pageRequest;

  @override
  bool operator ==(Object other) =>
      other is ItemCriteria &&
      other.ownerId == ownerId &&
      other.pageRequest == pageRequest;

  @override
  int get hashCode => Object.hash(ownerId, pageRequest);
}
