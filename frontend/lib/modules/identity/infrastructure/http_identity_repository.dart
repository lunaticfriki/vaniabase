import 'package:frontend/modules/identity/application/session_read_model.dart';
import 'package:frontend/modules/identity/infrastructure/acl/session_mapper.dart';
import 'package:frontend/shared/http/api_client.dart';

class HttpIdentityRepository {
  HttpIdentityRepository(this._client);

  final ApiClient _client;

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
