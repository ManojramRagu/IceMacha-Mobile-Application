import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({
    super.key,
    this.logoSize = 56,
    this.text = 'Welcome to IceMacha',
  });

  final double logoSize;
  final String text;

  static const _logo = 'assets/img/logo.webp';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        ClipOval(
          child: Container(
            width: logoSize,
            height: logoSize,
            color: Colors.white.withValues(alpha: 0.95),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              _logo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.local_cafe, color: cs.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}
