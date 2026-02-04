import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/providers/auth_provider.dart';
import 'package:icemacha/core/shell.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/screens/auth/login.dart';
import 'package:icemacha/screens/auth/register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isAuthenticated) {
      return const AppShell();
    }
    return const _AuthEntry();
  }
}

enum _Mode { login, register }

class _AuthEntry extends StatefulWidget {
  const _AuthEntry();

  @override
  State<_AuthEntry> createState() => _AuthEntryState();
}

class _AuthEntryState extends State<_AuthEntry> {
  _Mode _mode = _Mode.login;

  void _goLogin() => setState(() => _mode = _Mode.login);
  void _goRegister() => setState(() => _mode = _Mode.register);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final body = _mode == _Mode.login
        ? LoginScreen(onRegisterTap: _goRegister, onLoggedIn: () {})
        : RegisterScreen(onLoginTap: _goLogin, onRegistered: _goLogin);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final kb = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + kb),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _mode == _Mode.login
                            ? 'Sign in to IceMacha'
                            : 'Create your account',
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PageBodyNarrow(child: body),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
