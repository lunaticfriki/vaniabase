import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/modules/identity/application/remembered_account.dart';
import 'package:frontend/modules/identity/application/remembered_accounts_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalRememberedAccountsRepository implements RememberedAccountsRepository {
  LocalRememberedAccountsRepository(this._preferences, this._secureStorage);

  static const _emailsKey = 'remembered_accounts_emails';
  static const _maxAccounts = 5;

  final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage;

  String _passwordKey(String email) => 'remembered_account_password::$email';

  @override
  Future<List<RememberedAccount>> getAll() async {
    final emails = _preferences.getStringList(_emailsKey) ?? const [];
    return [
      for (final email in emails)
        RememberedAccount(
          email: email,
          password: await _secureStorage.read(key: _passwordKey(email)),
        ),
    ];
  }

  @override
  Future<void> remember({required String email, String? password}) async {
    final emails = _preferences.getStringList(_emailsKey) ?? const [];
    final reordered = [email, ...emails.where((existing) => existing != email)];
    final kept = reordered.take(_maxAccounts).toSet();
    await Future.wait([
      for (final dropped in reordered.skip(_maxAccounts))
        _secureStorage.delete(key: _passwordKey(dropped)),
    ]);
    await _preferences.setStringList(_emailsKey, kept.toList());

    if (password != null) {
      await _secureStorage.write(key: _passwordKey(email), value: password);
    } else {
      await _secureStorage.delete(key: _passwordKey(email));
    }
  }

  @override
  Future<void> forget(String email) async {
    final emails = _preferences.getStringList(_emailsKey) ?? const [];
    await _preferences.setStringList(
      _emailsKey,
      emails.where((existing) => existing != email).toList(),
    );
    await _secureStorage.delete(key: _passwordKey(email));
  }
}
