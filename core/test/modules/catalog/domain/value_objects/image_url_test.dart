import 'package:core/modules/catalog/domain/value_objects/image_url.dart';
import 'package:test/test.dart';

void main() {
  group('ImageUrl', () {
    test('create accepts a valid https URL', () {
      final url = ImageUrl.create('https://example.com/cover.jpg');

      expect(url.value, 'https://example.com/cover.jpg');
    });

    test('create accepts a valid http URL', () {
      final url = ImageUrl.create('http://example.com/cover.jpg');

      expect(url.value, 'http://example.com/cover.jpg');
    });

    test('create throws for a non-URL string', () {
      expect(
        () => ImageUrl.create('not a url'),
        throwsA(isA<InvalidImageUrlError>()),
      );
    });

    test('create throws for a URL with an unsupported scheme', () {
      expect(
        () => ImageUrl.create('ftp://example.com/cover.jpg'),
        throwsA(isA<InvalidImageUrlError>()),
      );
    });

    test('empty returns the neutral instance', () {
      expect(ImageUrl.empty().value, '');
    });

    test('equality is structural', () {
      expect(
        ImageUrl.create('https://example.com/cover.jpg'),
        equals(ImageUrl.create('https://example.com/cover.jpg')),
      );
    });
  });
}
