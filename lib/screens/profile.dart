import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/screens/auth/login.dart';
import 'package:icemacha/screens/auth/register.dart';
import 'package:icemacha/screens/auth/user_profile.dart';
import 'package:icemacha/screens/about.dart';
import 'package:icemacha/screens/contact.dart';

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

  Future<void> _showEditProfileSheet(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final nameCtrl = TextEditingController(text: auth.name);
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        final insets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Profile',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    controller: passCtrl,
                    label: 'New password (optional)',
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  PasswordField(
                    controller: confirmCtrl,
                    label: 'Confirm new password',
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      if (passCtrl.text.isEmpty && (v == null || v.isEmpty)) {
                        return null;
                      }
                      if (v != passCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Update'),
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ?? false))
                          return;
                        context.read<AuthProvider>().updateProfile(
                          name: nameCtrl.text,
                          password: passCtrl.text.isEmpty
                              ? null
                              : passCtrl.text,
                        );
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    nameCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
  }

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

          if (auth.isAuthenticated) ...[
            const SizedBox(height: 24),

            Text('Account', style: tt.titleMedium),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    subtitle: const Text(
                      'Change your display name or password',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showEditProfileSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text('Information', style: tt.titleMedium),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About App'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.contact_support_outlined),
                    title: const Text('Contact Us'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
