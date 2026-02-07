import 'package:flutter/material.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/models/receipt.dart';

class OrderPlacedScreen extends StatelessWidget {
  final OrderReceipt? receipt; // Optional, might come from args
  const OrderPlacedScreen({super.key, this.receipt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Extract receipt from route arguments if not provided in constructor
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as OrderReceipt?;
    final finalReceipt = receipt ?? routeArgs;

    if (finalReceipt == null) {
      // Fallback or error if no receipt
      return Scaffold(
        appBar: AppBar(title: const Text('Order placed 🎉')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Order Placed! Your IceMacha is being prepared.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final summaryLines = finalReceipt.lines
        .map(
          (l) =>
              SummaryLine(title: l.title, qty: l.qty, unitPrice: l.unitPrice),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Order placed 🎉')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // New success message
          Text(
            'Order Placed! IceMacha is preparing your order.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KeyValueRow(label: 'Order #', value: finalReceipt.orderNo),
                const SizedBox(height: 8),
                KeyValueRow(
                  label: 'Date',
                  value: finalReceipt.dateTime
                      .toLocal()
                      .toString()
                      .split('.')
                      .first,
                ),
                const SizedBox(height: 8),
                KeyValueRow(
                  label: 'Payment',
                  value: finalReceipt.paymentMethod,
                ),
                const SizedBox(height: 8),
                KeyValueRow(label: 'Delivery', value: finalReceipt.city),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ItemsSummaryCard(lines: summaryLines, total: finalReceipt.total),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Continue shopping'),
          ),
        ],
      ),
      backgroundColor: cs.surface,
    );
  }
}
