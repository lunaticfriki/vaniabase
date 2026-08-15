import 'package:core/shared/errors/domain_error.dart';

class SearchTerm {
  const SearchTerm._(this.value);

  factory SearchTerm.create(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      throw InvalidSearchTermError(value);
    }
    return SearchTerm._(trimmed);
  }

  factory SearchTerm.empty() => const SearchTerm._('');

  final String value;

  bool get isEmpty => value.isEmpty;

  bool matchesAny(Iterable<String> candidates) {
    if (isEmpty) return true;
    final needle = value.toLowerCase();
    return candidates
        .any((candidate) => candidate.toLowerCase().contains(needle));
  }

  @override
  bool operator ==(Object other) => other is SearchTerm && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidSearchTermError extends DomainError {
  InvalidSearchTermError(String value)
      : super('"$value" is not a valid search term (1-100 characters)');
}
