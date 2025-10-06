import 'package:flutter/material.dart';
import 'package:icemacha/widgets/footer.dart';
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

    setState(() {
      _formKey.currentState?.reset();
      _autoValidate = AutovalidateMode.disabled;
      _name.clear();
      _email.clear();
      _message.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
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

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: Validators.required('Name'),
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email(),
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _message,
                        decoration: const InputDecoration(labelText: 'Message'),
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
          ),

          const SizedBox(height: 24),
          const Footer(),
        ],
      ),
    );
  }
}
