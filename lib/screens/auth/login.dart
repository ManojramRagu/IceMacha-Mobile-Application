import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/utils/validation.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback onLoggedIn;
  const LoginScreen({
    super.key,
    required this.onRegisterTap,
    required this.onLoggedIn,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _auto = AutovalidateMode.disabled;

  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _busy = true);
    await context.read<AuthProvider>().login(
      email: _email.text,
      password: _password.text,
    );
    setState(() => _busy = false);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Signed in'),
        content: Text('Welcome back!'),
      ),
    );
    widget.onLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      autovalidateMode: _auto,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email(),
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _password,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              validator: Validators.compose([
                Validators.required('Password'),
                Validators.minLength(8, label: 'Password'),
              ]),
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.onRegisterTap,
                child: const Text("Don't have an account? Register"),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_busy ? 'Signing in…' : 'Sign in'),
                onPressed: _busy ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
