import 'package:core/shared/errors/domain_error.dart';

class DomainNumber {
  const DomainNumber._(this.value, this.decimalPlaces);

  factory DomainNumber.create(num value, {int decimalPlaces = 2}) {
    if (value.isNaN || value.isInfinite) {
      throw InvalidDomainNumberError('"$value" must be a finite number');
    }
    if (decimalPlaces < 0 || decimalPlaces > 10) {
      throw InvalidDomainNumberError(
        '"$decimalPlaces" decimalPlaces must be between 0 and 10',
      );
    }
    return DomainNumber._(value, decimalPlaces);
  }

  factory DomainNumber.empty() => const DomainNumber._(0, 2);

  final num value;
  final int decimalPlaces;

  String get formatted => value.toStringAsFixed(decimalPlaces);

  @override
  bool operator ==(Object other) =>
      other is DomainNumber &&
      other.value == value &&
      other.decimalPlaces == decimalPlaces;

  @override
  int get hashCode => Object.hash(value, decimalPlaces);

  @override
  String toString() => formatted;
}

class InvalidDomainNumberError extends DomainError {
  InvalidDomainNumberError(String reason) : super('invalid number: $reason');
}
