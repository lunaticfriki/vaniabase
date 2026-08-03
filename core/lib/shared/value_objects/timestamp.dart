import 'package:core/shared/errors/domain_error.dart';

class Timestamp {
  const Timestamp._(this.value);

  factory Timestamp.now() => Timestamp._(DateTime.now());

  factory Timestamp.create(DateTime value) {
    if (value.isAfter(DateTime.now())) {
      throw FutureTimestampError(value);
    }
    return Timestamp._(value);
  }

  factory Timestamp.at(DateTime value) => Timestamp._(value);

  factory Timestamp.empty() =>
      Timestamp._(DateTime.fromMillisecondsSinceEpoch(0));

  final DateTime value;

  bool isBefore(Timestamp other) => value.isBefore(other.value);

  bool isAfter(Timestamp other) => value.isAfter(other.value);

  @override
  bool operator ==(Object other) => other is Timestamp && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toIso8601String();
}

class FutureTimestampError extends DomainError {
  FutureTimestampError(DateTime value)
    : super('"$value" cannot be in the future');
}
