import 'package:core/shared/errors/domain_error.dart';
import 'package:core/shared/generate_uuid_util.dart';

final _uuidV4Pattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

class ItemId {
  const ItemId._(this.value);

  factory ItemId.generate() => ItemId._(generateUuidV4Util());

  factory ItemId.create(String value) {
    if (!_uuidV4Pattern.hasMatch(value)) {
      throw InvalidItemIdError(value);
    }
    return ItemId._(value);
  }

  factory ItemId.empty() =>
      const ItemId._('00000000-0000-0000-0000-000000000000');

  final String value;

  @override
  bool operator ==(Object other) => other is ItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidItemIdError extends DomainError {
  InvalidItemIdError(String value) : super('"$value" is not a valid item id');
}
