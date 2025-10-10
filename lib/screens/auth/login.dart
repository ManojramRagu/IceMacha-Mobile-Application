import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/validation.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/core/shell.dart';
import 'package:icemacha/widgets/welcome_header.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        const pad = EdgeInsets.fromLTRB(16, 20, 16, 24);
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final targetH = (constraints.maxHeight - pad.vertical).clamp(
          0.0,
          double.infinity,
        );

        return SingleChildScrollView(
          padding: pad.add(EdgeInsets.only(bottom: bottomInset)),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: targetH.toDouble()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const WelcomeHeader(),
                const SizedBox(height: 16),
                PageBodyNarrow(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _auto,
                    child: AuthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              'Login',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
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
                              child: const Text(
                                "Don't have an account? Register",
                              ),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
