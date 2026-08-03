import 'dart:convert';

import 'package:backend/shared/http/json_response_util.dart';
import 'package:backend/modules/identity/application/command/login_command.dart';
import 'package:backend/modules/identity/application/command/logout_command.dart';
import 'package:backend/modules/identity/application/command/refresh_session_command.dart';
import 'package:backend/modules/identity/application/command/register_user_command.dart';
import 'package:backend/modules/identity/application/identity_write_service.dart';
import 'package:backend/modules/identity/application/session_read_model.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router buildIdentityRouter(IdentityWriteService identity) {
  final router = Router();

  router.post('/auth/register', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final userId = await identity.register(
      RegisterUserCommand(
        email: body['email'] as String,
        username: body['username'] as String,
        password: body['password'] as String,
      ),
    );
    return jsonResponse(201, {'id': userId.value});
  });

  router.post('/auth/login', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final session = await identity.login(
      LoginCommand(
        email: body['email'] as String,
        password: body['password'] as String,
      ),
    );
    return jsonResponse(200, _sessionJson(session));
  });

  router.post('/auth/refresh', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final session = await identity.refresh(
      RefreshSessionCommand(refreshToken: body['refreshToken'] as String),
    );
    return jsonResponse(200, _sessionJson(session));
  });

  router.post('/auth/logout', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    await identity.logout(
      LogoutCommand(refreshToken: body['refreshToken'] as String),
    );
    return Response(204);
  });

  return router;
}

Map<String, dynamic> _sessionJson(SessionReadModel session) {
  return {
    'accessToken': session.accessToken,
    'accessTokenExpiresAt': session.accessTokenExpiresAt.toIso8601String(),
    'refreshToken': session.refreshToken,
  };
}
