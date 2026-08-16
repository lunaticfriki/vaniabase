import 'package:core/modules/catalog/domain/value_objects/format.dart';
import 'package:test/test.dart';

void main() {
  group('Format', () {
    test('parse accepts a valid format name', () {
      expect(Format.parse('hardcover'), Format.hardcover);
      expect(Format.parse('bluRay'), Format.bluRay);
      expect(Format.parse('vhs'), Format.vhs);
      expect(Format.parse('miniDisc'), Format.miniDisc);
    });

    test('parse throws for an unknown name', () {
      expect(
        () => Format.parse('not-a-format'),
        throwsA(isA<InvalidFormatError>()),
      );
    });
  });
}
