import 'package:core/modules/identity/domain/entities/user.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';
import 'package:core/modules/identity/domain/value_objects/user_id.dart';
import 'package:core/modules/identity/domain/value_objects/username.dart';
import 'package:core/shared/value_objects/timestamp.dart';

class UserMapper {
  static User toDomain(Map<String, dynamic> row) {
    return User.fromPersistence(
      id: UserId.create(row['id'] as String),
      email: Email.create(row['email'] as String),
      username: Username.create(row['username'] as String),
      passwordHash: PasswordHash.create(row['password_hash'] as String),
      createdAt: Timestamp.create(row['created_at'] as DateTime),
      updatedAt: Timestamp.create(row['updated_at'] as DateTime),
    );
  }

  static Map<String, dynamic> toPersistence(User user) {
    return {
      'id': user.id.value,
      'email': user.email.value,
      'username': user.username.value,
      'password_hash': user.passwordHash.value,
      'created_at': user.createdAt.value,
      'updated_at': user.updatedAt.value,
    };
  }
}
