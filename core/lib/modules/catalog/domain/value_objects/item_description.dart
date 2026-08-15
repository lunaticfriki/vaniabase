import 'package:core/shared/errors/domain_error.dart';

class ItemDescription {
  const ItemDescription._(this.value);

  factory ItemDescription.create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 2000) {
      throw InvalidItemDescriptionError(value);
    }
    return ItemDescription._(trimmed);
  }

  factory ItemDescription.empty() => const ItemDescription._('');

  final String value;

  @override
  bool operator ==(Object other) =>
      other is ItemDescription && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidItemDescriptionError extends DomainError {
  InvalidItemDescriptionError(String value)
      : super('"$value" is not a valid description (1-2000 characters)');
}
