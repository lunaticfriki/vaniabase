import 'package:frontend/modules/identity/application/session_read_model.dart';
import 'package:frontend/modules/identity/infrastructure/http_identity_repository.dart';

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

class IdentityWriteServiceImpl implements IdentityWriteService {
  IdentityWriteServiceImpl(this._repository);

  final HttpIdentityRepository _repository;

  @override
  Future<SessionReadModel> login({
    required String email,
    required String password,
  }) => _repository.login(email: email, password: password);

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) => _repository.register(
    email: email,
    username: username,
    password: password,
  );
}
