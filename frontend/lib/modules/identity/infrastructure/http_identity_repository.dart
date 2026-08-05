import 'package:frontend/modules/identity/application/identity_write_service.dart';
import 'package:frontend/modules/identity/application/session_read_model.dart';
import 'package:frontend/modules/identity/infrastructure/acl/session_mapper.dart';
import 'package:frontend/shared/http/api_client.dart';

class HttpIdentityRepository implements IdentityWriteService {
  HttpIdentityRepository(this._client);

  final ApiClient _client;

  @override
  Future<SessionReadModel> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return SessionMapper.toReadModel(json);
  }

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    await _client.post(
      '/auth/register',
      body: {'email': email, 'username': username, 'password': password},
    );
  }
}
