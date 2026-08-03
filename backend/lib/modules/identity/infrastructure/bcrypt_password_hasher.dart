import 'package:bcrypt/bcrypt.dart';
import 'package:core/modules/identity/domain/services/password_hasher.dart';
import 'package:core/modules/identity/domain/value_objects/password.dart';
import 'package:core/modules/identity/domain/value_objects/password_hash.dart';

class BcryptPasswordHasher implements PasswordHasher {
  @override
  PasswordHash hash(Password password) {
    final salt = BCrypt.gensalt();
    return PasswordHash.create(BCrypt.hashpw(password.value, salt));
  }

  @override
  bool verify(String candidate, PasswordHash hash) {
    return BCrypt.checkpw(candidate, hash.value);
  }
}
