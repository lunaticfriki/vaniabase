import 'package:frontend/modules/identity/application/session_read_model.dart';

class SessionMapper {
  static SessionReadModel toReadModel(Map<String, dynamic> json) {
    return SessionReadModel(
      accessToken: json['accessToken'] as String,
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt'] as String,
      ),
      refreshToken: json['refreshToken'] as String,
    );
  }
}
