import 'dart:io';

const _forbiddenEdges = <String, List<String>>{
  'application': ['infrastructure', 'presentation'],
  'infrastructure': ['presentation'],
  'presentation': ['infrastructure'],
};

final _importPattern = RegExp(r'''^\s*import\s+['"]([^'"]+)['"]''', multiLine: true);

void main() {
  final modulesDir = Directory('lib/modules');
  if (!modulesDir.existsSync()) {
    stderr.writeln('arch_test: lib/modules not found — run from the frontend/ directory.');
    exit(2);
  }

  final violations = <String>[];

  for (final moduleEntity in modulesDir.listSync()) {
    if (moduleEntity is! Directory) continue;

    for (final MapEntry(key: layer, value: forbiddenLayers) in _forbiddenEdges.entries) {
      final layerDir = Directory('${moduleEntity.path}/$layer');
      if (!layerDir.existsSync()) continue;

      for (final file in _dartFilesUnder(layerDir)) {
        for (final import in _importsOf(file)) {
          for (final forbiddenLayer in forbiddenLayers) {
            if (_crossesInto(import, forbiddenLayer)) {
              violations.add(
                '${file.path}: imports "$import" ($layer must not depend on $forbiddenLayer)',
              );
            }
          }
        }
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('arch_test: ${violations.length} violation(s) found:\n');
    stderr.writeln(violations.join('\n'));
    exit(1);
  }

  stdout.writeln('arch_test: no violations found.');
}

Iterable<File> _dartFilesUnder(Directory dir) {
  return dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
}

Iterable<String> _importsOf(File file) {
  return _importPattern.allMatches(file.readAsStringSync()).map((m) => m.group(1)!);
}

bool _crossesInto(String import, String layer) {
  return import.contains('/$layer/');
}
