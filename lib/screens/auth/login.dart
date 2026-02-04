import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/validation.dart';
import 'package:icemacha/providers/auth_provider.dart';
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

  bool _isLoading = false;

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

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().login(
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      // Success
      setState(() => _isLoading = false);
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String message = 'An unexpected error occurred';
      final errStr = e.toString();
      if (errStr.contains('401')) {
        message = 'Invalid email or password';
      } else if (errStr.contains('422')) {
        message = 'Please check your input data';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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
                              Validators.minLength(8, label: 'Password'),
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
                              busy: _isLoading,
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
