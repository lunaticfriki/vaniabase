import 'package:frontend/modules/identity/application/remembered_account.dart';

abstract class RememberedAccountsRepository {
  Future<List<RememberedAccount>> getAll();

  Future<void> remember({required String email, String? password});

  Future<void> forget(String email);
}
