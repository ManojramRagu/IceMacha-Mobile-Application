import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        'Checkout',
        style: tt.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
    );
  }
}
