import 'package:flutter/material.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/screens/menu.dart';

class OrderLineView {
  final String title;
  final int qty;
  final int unitPrice;
  const OrderLineView({
    required this.title,
    required this.qty,
    required this.unitPrice,
  });
}

class OrderReceipt {
  final String orderNo;
  final DateTime dateTime;
  final String paymentMethod;
  final String city;
  final List<OrderLineView> lines;
  final int total;
  const OrderReceipt({
    required this.orderNo,
    required this.dateTime,
    required this.paymentMethod,
    required this.city,
    required this.lines,
    required this.total,
  });
}

class OrderPlacedScreen extends StatelessWidget {
  final OrderReceipt receipt;
  const OrderPlacedScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final summaryLines = receipt.lines
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
          AuthCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KeyValueRow(label: 'Order #', value: receipt.orderNo),
                const SizedBox(height: 8),
                KeyValueRow(
                  label: 'Date',
                  value: receipt.dateTime.toLocal().toString().split('.').first,
                ),
                const SizedBox(height: 8),
                KeyValueRow(label: 'Payment', value: receipt.paymentMethod),
                const SizedBox(height: 8),
                // Will display "Home" or the entered address string
                KeyValueRow(label: 'Delivery', value: receipt.city),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ItemsSummaryCard(lines: summaryLines, total: receipt.total),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              );
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
