import 'package:frontend/modules/identity/application/session_read_model.dart';

abstract class IdentityWriteService {
  Future<SessionReadModel> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String email,
    required String username,
    required String password,
  });
}
