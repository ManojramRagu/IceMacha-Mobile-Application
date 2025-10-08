import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/auth_provider.dart';

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
    // ========== NEW ============
    _name = TextEditingController(
      text: ap.displayName == 'Guest' ? '' : ap.displayName,
    );
    //========== END OF NEW ============
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Display name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pass,
                decoration: const InputDecoration(
                  labelText: 'New password (optional)',
                ),
                obscureText: true,
              ),
              TextFormField(
                controller: _confirm,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                ),
                obscureText: true,
                validator: (v) {
                  if (_pass.text.isEmpty && (v == null || v.isEmpty))
                    return null;
                  if (_pass.text.length < 6) return 'Min 6 characters';
                  if (v != _pass.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _update, child: const Text('Update')),
            ],
          ),
        ),
      ),
    );
  }
}
