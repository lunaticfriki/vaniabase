import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/modules/identity/application/identity_write_service.dart';

class FirebaseIdentityRepository implements IdentityWriteService {
  FirebaseIdentityRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw Exception(error.message ?? error.code);
    }
  }

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(username);
    } on FirebaseAuthException catch (error) {
      throw Exception(error.message ?? error.code);
    }
  }
}
