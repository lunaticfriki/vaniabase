import 'package:core/shared/errors/domain_error.dart';

class PublicationYear {
  const PublicationYear._(this.value);

  factory PublicationYear.create(int value) {
    if (value < 1000 || value > DateTime.now().year) {
      throw InvalidPublicationYearError(value);
    }
    return PublicationYear._(value);
  }

  factory PublicationYear.empty() => const PublicationYear._(0);

  final int value;

  @override
  bool operator ==(Object other) =>
      other is PublicationYear && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

class InvalidPublicationYearError extends DomainError {
  InvalidPublicationYearError(int value)
      : super('"$value" is not a valid publication year');
}
