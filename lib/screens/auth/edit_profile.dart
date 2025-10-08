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
    _name = TextEditingController(
      text: ap.displayName == 'Guest' ? '' : ap.displayName,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _update() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newName = _name.text.trim();
    final newPass = _pass.text.trim();

    context.read<AuthProvider>().updateProfile(
      name: newName,
      password: newPass.isEmpty ? null : newPass,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: PageBodyNarrow(
          child: Form(
            key: _formKey,
            child: AuthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    controller: _pass,
                    label: 'New password (optional)',
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return null;
                      if (s.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  PasswordField(
                    controller: _confirm,
                    label: 'Confirm new password',
                    textInputAction: TextInputAction.done,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (_pass.text.trim().isEmpty && s.isEmpty) return null;
                      if (s != _pass.text.trim()) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: PrimaryBusyButton(
                      busy: false,
                      label: 'Update',
                      busyLabel: 'Updating…',
                      icon: Icons.check_rounded,
                      onPressed: _update,
                    ),
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
