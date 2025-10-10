import 'package:flutter/material.dart';
import 'package:icemacha/widgets/app_nav.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/utils/validation.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      setState(() => _autoValidate = AutovalidateMode.onUserInteraction);
      return;
    }

    FocusScope.of(context).unfocus();

    await showDialog<void>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Message sent'),
        content: Text('Thank you for your feedback'),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Contact IceMacha',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              PageBodyNarrow(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NameField(controller: _name),
                        const SizedBox(height: 12),

                        EmailField(controller: _email),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _message,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                          ),
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          validator: Validators.required('Message'),
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.send_rounded),
                            label: const Text('Send'),
                            onPressed: _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
