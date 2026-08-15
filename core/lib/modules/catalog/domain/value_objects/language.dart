import 'package:core/shared/errors/domain_error.dart';

final _languageCodePattern = RegExp(r'^[a-z]{2}$');

class Language {
  const Language._(this.value);

  factory Language.create(String value) {
    final normalized = value.trim().toLowerCase();
    if (!_languageCodePattern.hasMatch(normalized)) {
      throw InvalidLanguageError(value);
    }
    return Language._(normalized);
  }

  factory Language.empty() => const Language._('');

  final String value;

  @override
  bool operator ==(Object other) => other is Language && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidLanguageError extends DomainError {
  InvalidLanguageError(String value)
      : super('"$value" is not a valid 2-letter language code');
}
