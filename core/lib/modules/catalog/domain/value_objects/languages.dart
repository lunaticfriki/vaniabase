import 'package:core/modules/catalog/domain/value_objects/language.dart';
import 'package:core/shared/list_equals_util.dart';

class Languages {
  const Languages._(this.value);

  factory Languages.create(List<Language> languages) {
    final deduped = <Language>[];
    for (final language in languages) {
      if (!deduped.contains(language)) {
        deduped.add(language);
      }
    }
    return Languages._(List.unmodifiable(deduped));
  }

  factory Languages.empty() => const Languages._([]);

  final List<Language> value;

  bool contains(Language language) => value.contains(language);

  @override
  bool operator ==(Object other) =>
      other is Languages && listEqualsUtil(other.value, value);

  @override
  int get hashCode => Object.hashAll(value);

  @override
  String toString() => value.map((language) => language.value).join(', ');
}
