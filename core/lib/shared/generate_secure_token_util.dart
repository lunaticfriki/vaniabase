import 'dart:math';

final _random = Random.secure();

String generateSecureTokenUtil() {
  final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
