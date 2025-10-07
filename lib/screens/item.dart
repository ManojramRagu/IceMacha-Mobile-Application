import 'package:flutter/material.dart';
import 'package:icemacha/utils/product.dart';

class ItemScreen extends StatelessWidget {
  final Product product;
  const ItemScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final tt = t.textTheme;

    final title = product.title;
    final desc = product.description.trim().isNotEmpty
        ? product.description
        : 'A delicious $title made fresh for you.';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: cs.surface,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Image (safe fallback so page never blanks)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: cs.surfaceVariant),
                  Image.asset(
                    product.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.broken_image,
                        color: cs.onSurfaceVariant,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(desc, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 16),

          // Price
          Text(
            'LKR ${product.price}',
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Button with FINITE constraints (no Row, no Spacer)
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40, // gives the button concrete constraints
              child: FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Added $title')));
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
