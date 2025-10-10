import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/screens/auth/login.dart';
import 'package:icemacha/screens/auth/register.dart';
import 'package:icemacha/screens/auth/user_profile.dart';
import 'package:icemacha/screens/auth/edit_profile.dart';
import 'package:icemacha/screens/about.dart';
import 'package:icemacha/screens/contact.dart';
import 'package:icemacha/utils/theme_provider.dart';
import 'package:icemacha/core/responsive.dart';

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
    final auth = context.watch<AuthProvider>();
    final wide = isWide(MediaQuery.sizeOf(context).width);

    if (!auth.isAuthenticated) {
      return _mode == _Mode.login
          ? LoginScreen(
              onRegisterTap: _goRegister,
              onLoggedIn: () {
                if (!mounted) return;
                setState(() {});
              },
            )
          : RegisterScreen(onLoginTap: _goLogin, onRegistered: _goLogin);
    }

    final Widget body = const UserProfile();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: PageBodyNarrow(child: body)),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Account',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 0,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Edit Profile'),
                                subtitle: const Text(
                                  'Change your name or password',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Appearance',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 0,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Consumer<ThemeProvider>(
                            builder: (context, theme, _) {
                              final systemIsDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              final subtitle = theme.mode == ThemeMode.system
                                  ? 'Follows device (${systemIsDark ? 'dark' : 'light'})'
                                  : (theme.isDark ? 'Dark' : 'Light');
                              return SwitchListTile(
                                secondary: const Icon(Icons.dark_mode_outlined),
                                title: const Text('Dark mode'),
                                subtitle: Text(subtitle),
                                value: theme.isDark,
                                onChanged: (_) => theme.toggle(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 0,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text('About App'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AboutScreen(),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(
                                  Icons.contact_support_outlined,
                                ),
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
                    ),
                  ),
                ),
              ],
            )
          else ...[
            PageBodyNarrow(child: body),
            const SizedBox(height: 24),
            Text('Account', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    subtitle: const Text('Change your name or password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Consumer<ThemeProvider>(
                builder: (context, theme, _) {
                  final systemIsDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final subtitle = theme.mode == ThemeMode.system
                      ? 'Follows device (${systemIsDark ? 'dark' : 'light'})'
                      : (theme.isDark ? 'Dark' : 'Light');
                  return SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark mode'),
                    subtitle: Text(subtitle),
                    value: theme.isDark,
                    onChanged: (_) => theme.toggle(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Information', style: Theme.of(context).textTheme.titleMedium),
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
