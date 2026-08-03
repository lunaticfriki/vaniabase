import 'package:core/modules/identity/domain/entities/refresh_token.dart';

import 'user_mother.dart';

class RefreshTokenMother {
  static RefreshToken random() => RefreshToken.issue(
    userId: UserMother.random().id,
    validFor: const Duration(days: 30),
  );

  static RefreshToken empty() => RefreshToken.empty();
}
