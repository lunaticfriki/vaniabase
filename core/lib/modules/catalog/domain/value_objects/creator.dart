import 'package:core/shared/errors/domain_error.dart';
import 'package:core/shared/list_equals_util.dart';

class Creator {
  const Creator._(this.names);

  factory Creator.create(List<String> names) {
    final normalized = <String>[];
    final seen = <String>{};
    for (final rawName in names) {
      final trimmed = rawName.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.length > 100) {
        throw InvalidCreatorError('"$trimmed" exceeds 100 characters');
      }
      final key = trimmed.toLowerCase();
      if (seen.add(key)) {
        normalized.add(trimmed);
      }
    }
    if (normalized.isEmpty) {
      throw InvalidCreatorError('at least one name is required');
    }
    return Creator._(List.unmodifiable(normalized));
  }

  factory Creator.single(String name) => Creator.create([name]);

  factory Creator.empty() => const Creator._([]);

  final List<String> names;

  String get displayName => names.join(', ');

  @override
  bool operator ==(Object other) =>
      other is Creator && listEqualsUtil(other.names, names);

  @override
  int get hashCode => Object.hashAll(names);

  @override
  String toString() => displayName;
}

class InvalidCreatorError extends DomainError {
  InvalidCreatorError(String reason) : super('invalid creator: $reason');
}
