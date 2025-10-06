import 'package:flutter/material.dart';
import 'package:icemacha/utils/product.dart';
import 'package:icemacha/widgets/product_card.dart';

class MenuSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final bool expanded;
  final VoidCallback? onToggleExpand;
  final void Function(Product)? onSelect;

  const MenuSection({
    super.key,
    required this.title,
    required this.products,
    required this.expanded,
    this.onToggleExpand,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, c) {
        const gap = 12.0;
        const horizontalPad = 16.0;
        final usable = c.maxWidth - (horizontalPad * 2) - gap; // 2-up width
        final cardWidth = usable / 2;

        Widget header(String linkText) => Padding(
          padding: const EdgeInsets.fromLTRB(
            horizontalPad,
            8,
            horizontalPad,
            6,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: onToggleExpand, child: Text(linkText)),
            ],
          ),
        );

        if (!expanded) {
          // Horizontal scroller: 2 cards visible at once; scroll for more
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header('Show more…'),
              SizedBox(
                height: cardWidth + 118,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPad,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: gap),
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return ProductCard(
                      product: p,
                      width: cardWidth,
                      onTap: onSelect == null ? null : () => onSelect!(p),
                      onAdd: null, // cart later
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }

        // Expanded grid (inline)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header('Close'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPad),
              child: Wrap(
                spacing: gap,
                runSpacing: gap,
                children: products.map((p) {
                  return ProductCard(
                    product: p,
                    width: cardWidth,
                    onTap: onSelect == null ? null : () => onSelect!(p),
                    onAdd: null,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
