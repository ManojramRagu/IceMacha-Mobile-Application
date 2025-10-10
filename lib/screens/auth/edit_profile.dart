import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/widgets/form.dart'; // NameField

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
    // If name is "Guest", start blank to nudge setting a real name
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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ========== NEW ============
              // Use shared NameField (letters + spaces only)
              NameField(
                controller: _name,
                textInputAction: TextInputAction.next,
              ),
              //========== END OF NEW ============
              const SizedBox(height: 12),

              TextFormField(
                controller: _pass,
                decoration: const InputDecoration(
                  labelText: 'New password (optional)',
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: _confirm,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                ),
                obscureText: true,
                validator: (v) {
                  // Password change is optional; only validate when provided
                  if (_pass.text.isEmpty && (v == null || v.isEmpty)) {
                    return null;
                  }
                  if (_pass.text.length < 6) return 'Min 6 characters';
                  if (v != _pass.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              FilledButton(
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
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
                  // Go back to Profile (no redirects to Home)
                  Navigator.of(context).pop();
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
