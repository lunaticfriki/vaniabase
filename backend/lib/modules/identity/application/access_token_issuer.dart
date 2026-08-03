import 'package:core/modules/identity/domain/value_objects/user_id.dart';

abstract class AccessTokenIssuer {
  IssuedAccessToken issue(UserId userId);

  UserId? verify(String token);
}

class IssuedAccessToken {
  const IssuedAccessToken({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;
}
