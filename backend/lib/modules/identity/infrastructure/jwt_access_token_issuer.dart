import 'package:backend/modules/identity/application/access_token_issuer.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtAccessTokenIssuer implements AccessTokenIssuer {
  JwtAccessTokenIssuer(this._secret, {this.ttl = const Duration(minutes: 15)});

  final String _secret;
  final Duration ttl;

  @override
  IssuedAccessToken issue(UserId userId) {
    final jwt = JWT({'sub': userId.value});
    final token = jwt.sign(SecretKey(_secret), expiresIn: ttl);
    return IssuedAccessToken(token: token, expiresAt: DateTime.now().add(ttl));
  }

  @override
  UserId? verify(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      final payload = jwt.payload as Map;
      return UserId.create(payload['sub'] as String);
    } on JWTException {
      return null;
    }
  }
}
