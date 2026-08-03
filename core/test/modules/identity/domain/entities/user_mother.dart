import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';

class UserMother {
  static User random() => User.register(
    email: Email.create('jane.doe@example.com'),
    username: Username.create('jane_doe'),
    passwordHash: PasswordHash.create('hashed-password-value'),
  );

  static User empty() => User.empty();
}
