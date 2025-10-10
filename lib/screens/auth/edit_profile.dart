import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/widgets/form.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ap = context.read<AuthProvider>();
    final initial = ap.name.trim() == 'Guest' ? '' : ap.name.trim();
    _name = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _name.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: PageBodyNarrow(
          child: Form(
            key: _formKey,
            child: AuthCard(
              child: Column(
                children: [
                  NameField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  // Optional new password
                  PasswordField(
                    controller: _pass,
                    label: 'New password (optional)',
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return null;
                      if (s.length < 8) return 'Min 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Confirm new password
                  PasswordField(
                    controller: _confirm,
                    label: 'Confirm new password',
                    validator: (v) {
                      final p = _pass.text.trim();
                      final c = (v ?? '').trim();
                      if (p.isEmpty && c.isEmpty) return null;
                      if (p.length < 8) return 'Min 8 characters';
                      if (c != p) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Primary button
                  FilledButton(
                    onPressed: () {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      context.read<AuthProvider>().updateProfile(
                        name: _name.text,
                        password: _pass.text.isEmpty ? null : _pass.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      // Return to Profile screen
                      Navigator.of(context).pop();
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
