import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:core/shared/errors/domain_error.dart';
import 'package:core/shared/list_equals_util.dart';

class ItemFormats {
  const ItemFormats._(this.value);

  factory ItemFormats.create(List<Format> formats) {
    final deduped = <Format>[];
    for (final format in formats) {
      if (!deduped.contains(format)) {
        deduped.add(format);
      }
    }
    if (deduped.isEmpty) {
      throw InvalidItemFormatsError('at least one format is required');
    }
    return ItemFormats._(List.unmodifiable(deduped));
  }

  factory ItemFormats.empty() => const ItemFormats._([]);

  final List<Format> value;

  bool contains(Format format) => value.contains(format);

  @override
  bool operator ==(Object other) =>
      other is ItemFormats && listEqualsUtil(other.value, value);

  @override
  int get hashCode => Object.hashAll(value);

  @override
  String toString() => value.map((format) => format.name).join(', ');
}

class InvalidItemFormatsError extends DomainError {
  InvalidItemFormatsError(String reason) : super('invalid formats: $reason');
}
