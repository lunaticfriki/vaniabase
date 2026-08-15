import 'package:flutter/material.dart';
import 'package:frontend/modules/identity/application/remembered_account.dart';
import 'package:pixelarticons/pixel.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    required this.isSubmitting,
    required this.errorMessage,
    required this.rememberedAccounts,
    required this.onSubmit,
    required this.onForgetAccount,
    required this.onNavigateToSignup,
    super.key,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final List<RememberedAccount> rememberedAccounts;
  final void Function({
    required String email,
    required String password,
    required bool rememberPassword,
  })
  onSubmit;
  final void Function(String email) onForgetAccount;
  final VoidCallback onNavigateToSignup;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectAccount(RememberedAccount account) {
    setState(() {
      _emailController.text = account.email;
      if (account.hasSavedPassword) {
        _passwordController.text = account.password!;
        _rememberPassword = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Log in',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (widget.rememberedAccounts.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _RememberedAccountsList(
                      accounts: widget.rememberedAccounts,
                      onSelect: _selectAccount,
                      onForget: widget.onForgetAccount,
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Email is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Pixel.eye : Pixel.eyeclosed,
                        ),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Password is required'
                        : null,
                  ),
                  CheckboxListTile(
                    value: _rememberPassword,
                    onChanged: (value) =>
                        setState(() => _rememberPassword = value ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Remember password on this device'),
                  ),
                  const SizedBox(height: 4),
                  if (widget.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        widget.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: widget.isSubmitting ? null : _submit,
                    child: widget.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log in'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.isSubmitting
                        ? null
                        : widget.onNavigateToSignup,
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberPassword: _rememberPassword,
    );
  }
}

class _RememberedAccountsList extends StatelessWidget {
  const _RememberedAccountsList({
    required this.accounts,
    required this.onSelect,
    required this.onForget,
  });

  final List<RememberedAccount> accounts;
  final void Function(RememberedAccount account) onSelect;
  final void Function(String email) onForget;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final account in accounts)
            InputChip(
              avatar: const Icon(Pixel.user, size: 16),
              label: Text(account.email),
              onPressed: () => onSelect(account),
              onDeleted: () => onForget(account.email),
              deleteIcon: const Icon(Pixel.close, size: 16),
            ),
        ],
      ),
    );
  }
}
