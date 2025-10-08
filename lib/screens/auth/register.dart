import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/validation.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/widgets/form.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegistered;

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
  final _address = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _busy = true);
    await context.read<AuthProvider>().register(
      email: _email.text,
      password: _password.text,
      address: _address.text,
    );
    setState(() => _busy = false);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Registered'),
        content: Text('Account created. Please sign in to continue.'),
      ),
    );

    widget.onRegistered();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: _auto,
      child: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EmailField(controller: _email),
            const SizedBox(height: 12),
            PasswordField(
              controller: _password,
              label: 'Password (min 8)',
              textInputAction: TextInputAction.next,
              validator: Validators.compose([
                Validators.required('Password'),
                Validators.minLength(8, label: 'Password'),
              ]),
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _confirm,
              label: 'Confirm password',
              textInputAction: TextInputAction.next,
              validator: Validators.compose([
                Validators.required('Confirm password'),
                Validators.match(_password, message: 'Passwords do not match'),
              ]),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Home address (optional)',
                hintText: 'e.g., 23 Flower Rd, Colombo 7',
              ),
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
              child: PrimaryBusyButton(
                busy: _busy,
                label: 'Create account',
                busyLabel: 'Creating…',
                icon: Icons.person_add_alt_1,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
