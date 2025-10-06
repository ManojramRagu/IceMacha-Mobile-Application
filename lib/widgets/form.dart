import 'package:flutter/material.dart';
import 'package:icemacha/utils/validation.dart';

class PageBodyNarrow extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const PageBodyNarrow({super.key, required this.child, this.maxWidth = 520});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;

  const EmailField({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      validator: Validators.email(label),
      autofillHints: const [AutofillHints.email],
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        ),
      ),
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
    );
  }
}

class PrimaryBusyButton extends StatelessWidget {
  final bool busy;
  final String label;
  final String? busyLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  const PrimaryBusyButton({
    super.key,
    required this.busy,
    required this.label,
    required this.icon,
    this.busyLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(busy ? (busyLabel ?? '$label…') : label),
      onPressed: busy ? null : onPressed,
    );
  }
}
