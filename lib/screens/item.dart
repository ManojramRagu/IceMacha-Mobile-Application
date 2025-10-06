import 'package:flutter/material.dart';
import 'package:icemacha/utils/product.dart';

class ItemScreen extends StatelessWidget {
  final Product product;
  const ItemScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(product.imagePath, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              product.title,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Description (fallback text if empty in JSON)
            Text(
              (product.description?.trim().isNotEmpty == true)
                  ? product.description!
                  : 'A delicious ${product.title} made fresh for you.',
              style: tt.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Price + Add
            Row(
              children: [
                Text(
                  'LKR ${product.price}',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    // Cart wiring comes next; show feedback for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${product.title}')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
