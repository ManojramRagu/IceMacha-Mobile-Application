// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/validation.dart';
import 'package:icemacha/utils/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegistered; // call to go back to Login
  const RegisterScreen({
    super.key,
    required this.onLoginTap,
    required this.onRegistered,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _auto = AutovalidateMode.disabled;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidePw = true;
  bool _hideConfirm = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _busy = true);
    // For demo: this does nothing (no persistence)
    await context.read<AuthProvider>().register(
      email: _email.text,
      password: _password.text,
    );
    setState(() => _busy = false);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Registered'),
        content: Text('Account created (demo). Please sign in to continue.'),
      ),
    );

    widget.onRegistered(); // go back to login
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
                labelText: 'Password (min 8)',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hidePw = !_hidePw),
                  icon: Icon(_hidePw ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              obscureText: _hidePw,
              textInputAction: TextInputAction.next,
              validator: Validators.compose([
                Validators.required('Password'),
                Validators.minLength(8, label: 'Password'),
              ]),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _confirm,
              decoration: InputDecoration(
                labelText: 'Confirm password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                  icon: Icon(
                    _hideConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              obscureText: _hideConfirm,
              textInputAction: TextInputAction.done,
              validator: Validators.compose([
                Validators.required('Confirm password'),
                Validators.match(_password, message: 'Passwords do not match'),
              ]),
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.onLoginTap,
                child: const Text('Already have an account? Login'),
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
                    : const Icon(Icons.person_add_alt_1),
                label: Text(_busy ? 'Creating…' : 'Create account'),
                onPressed: _busy ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
