import 'package:core/modules/catalog/domain/value_objects/tag.dart';
import 'package:core/shared/errors/domain_error.dart';
import 'package:core/shared/list_equals_util.dart';

class ItemTags {
  const ItemTags._(this.value);

  factory ItemTags.create(List<Tag> tags) {
    final deduped = <Tag>[];
    for (final tag in tags) {
      if (!deduped.contains(tag)) {
        deduped.add(tag);
      }
    }
    if (deduped.length > 10) {
      throw InvalidItemTagsError(deduped.length);
    }
    return ItemTags._(List.unmodifiable(deduped));
  }

  factory ItemTags.empty() => const ItemTags._([]);

  final List<Tag> value;

  int get count => value.length;

  bool contains(Tag tag) => value.contains(tag);

  @override
  bool operator ==(Object other) =>
      other is ItemTags && listEqualsUtil(other.value, value);

  @override
  int get hashCode => Object.hashAll(value);

  @override
  String toString() => value.join(', ');
}

class InvalidItemTagsError extends DomainError {
  InvalidItemTagsError(int count)
    : super('an item cannot have more than 10 tags (got $count)');
}
