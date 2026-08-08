abstract class IdentityWriteService {
  Future<void> login({required String email, required String password});

  Future<void> register({
    required String email,
    required String username,
    required String password,
  });
}
