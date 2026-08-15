class RememberedAccount {
  const RememberedAccount({required this.email, this.password});

  final String email;
  final String? password;

  bool get hasSavedPassword => password != null;
}
