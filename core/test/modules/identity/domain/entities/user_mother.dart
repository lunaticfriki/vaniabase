import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:core/shared/generate_uuid_util.dart';

class UserMother {
  static User random() {
    final suffix = generateUuidV4Util().substring(0, 8);
    return User.register(
      email: Email.create('jane.doe+$suffix@example.com'),
      username: Username.create('jane_doe_$suffix'),
      passwordHash: PasswordHash.create('hashed-password-value'),
    );
  }

  static User empty() => User.empty();
}
