import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/validation.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/core/shell.dart';

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
    final ok = await context.read<AuthProvider>().login(
      email: _email.text,
      password: _password.text,
    );
    setState(() => _busy = false);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onLoggedIn();

    final routeName = ModalRoute.of(context)?.settings.name;
    final isStandalone =
        routeName == '/login' || !Navigator.of(context).canPop();
    if (isStandalone) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell(initialTabIndex: 0)),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      autovalidateMode: _auto,
      child: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Login',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),

            EmailField(controller: _email),
            const SizedBox(height: 12),
            PasswordField(
              controller: _password,
              label: 'Password',
              textInputAction: TextInputAction.done,
              validator: Validators.compose([
                Validators.required('Password'),
                Validators.minLength(6, label: 'Password'),
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
              child: PrimaryBusyButton(
                busy: _busy,
                label: 'Sign in',
                busyLabel: 'Signing in…',
                icon: Icons.login,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
