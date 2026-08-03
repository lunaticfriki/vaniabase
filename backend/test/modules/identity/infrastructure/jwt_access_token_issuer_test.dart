import 'package:backend/modules/identity/infrastructure/jwt_access_token_issuer.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:test/test.dart';

void main() {
  group('JwtAccessTokenIssuer', () {
    test('issue then verify returns the original user id', () {
      final issuer = JwtAccessTokenIssuer('test-secret');
      final userId = UserId.generate();

      final issued = issuer.issue(userId);

      expect(issuer.verify(issued.token), userId);
    });

    test('verify returns null for a garbage token', () {
      final issuer = JwtAccessTokenIssuer('test-secret');

      expect(issuer.verify('not-a-jwt'), isNull);
    });

    test('verify returns null for a token signed with a different secret', () {
      final issuer = JwtAccessTokenIssuer('test-secret');
      final otherIssuer = JwtAccessTokenIssuer('other-secret');
      final issued = otherIssuer.issue(UserId.generate());

      expect(issuer.verify(issued.token), isNull);
    });

    test('verify returns null for an expired token', () async {
      final issuer = JwtAccessTokenIssuer(
        'test-secret',
        ttl: const Duration(milliseconds: 1),
      );
      final issued = issuer.issue(UserId.generate());

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(issuer.verify(issued.token), isNull);
    });
  });
}
