import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
    required this.onNavigateToSignup,
    super.key,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final void Function({required String email, required String password})
  onSubmit;
  final VoidCallback onNavigateToSignup;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Password is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
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
    );
  }
}
