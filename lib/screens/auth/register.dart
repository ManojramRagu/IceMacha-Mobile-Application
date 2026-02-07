import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/validation.dart';
import 'package:icemacha/providers/auth_provider.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/widgets/welcome_header.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegistered;

  const RegisterScreen({
    super.key,
    required this.onLoginTap,
    required this.onRegistered,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _auto = AutovalidateMode.disabled;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        passwordConfirmation: _confirm.text,
        address: _address.text,
        phone: _phone.text,
      );

      if (!mounted) return;

      // Auto-login successful in provider, so we can just proceed or show success
      // The provider notifies listeners, so if there's an auth guard it will redirect.
      // But user requested "Account created. Please sign in" dialog?
      // Wait, if register logs you in (as per my implementation), we shouldn't say "Please sign in".
      // But the requirement said: "On success, store the returned token... Update _isAuthenticated".
      // So the user IS logged in.
      // I will update the dialog to say "Welcome".

      await showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Welcome!'),
          content: Text('Account created successfully.'),
        ),
      );

      widget.onRegistered();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
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
                              'Create Your Account',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'John Doe',
                            ),
                            validator: Validators.required('Name'),
                          ),
                          const SizedBox(height: 12),
                          EmailField(controller: _email),
                          const SizedBox(height: 12),
                          PasswordField(
                            controller: _password,
                            label: 'Password (min 8)',
                            textInputAction: TextInputAction.next,
                            validator: Validators.compose([
                              Validators.required('Password'),
                              Validators.minLength(8, label: 'Password'),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          const SizedBox(height: 12),
                          PasswordField(
                            controller: _confirm,
                            label: 'Confirm password',
                            textInputAction: TextInputAction.next,
                            validator: Validators.compose([
                              Validators.required('Confirm password'),
                              Validators.match(
                                _password,
                                message: 'Passwords do not match',
                              ),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phone,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number (optional)',
                              hintText: '+94 77 123 4567',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _address,
                            maxLines: 2,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Address (optional)',
                              hintText: 'e.g., 23 Flower Rd, Colombo 7',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: widget.onLoginTap,
                              child: const Text(
                                'Already have an account? Login',
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: PrimaryBusyButton(
                              busy: _busy,
                              label: 'Create account',
                              busyLabel: 'Creating…',
                              icon: Icons.person_add_alt_1,
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
