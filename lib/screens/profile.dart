import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/screens/auth/login.dart';
import 'package:icemacha/screens/auth/register.dart';
import 'package:icemacha/screens/auth/user_profile.dart';

enum _Mode { login, register }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _Mode _mode = _Mode.login;

  void _goLogin() => setState(() => _mode = _Mode.login);
  void _goRegister() => setState(() => _mode = _Mode.register);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    final Widget body = auth.isAuthenticated
        ? const UserProfile()
        : (_mode == _Mode.login
              ? LoginScreen(onRegisterTap: _goRegister, onLoggedIn: () {})
              : RegisterScreen(onLoginTap: _goLogin, onRegistered: _goLogin));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Your Account',
              style: tt.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          PageBodyNarrow(child: body),
        ],
      ),
    );
  }
}
