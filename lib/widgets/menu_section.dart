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

        final usable = c.maxWidth - (horizontalPad * 2) - gap;
        final cardWidth = usable / 2;
        const contentHeight = 156.0;
        final cardHeight = cardWidth + contentHeight;

        Widget header(String linkText) => Padding(
          padding: const EdgeInsets.fromLTRB(
            horizontalPad,
            8,
            horizontalPad,
            6,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: onToggleExpand, child: Text(linkText)),
            ],
          ),
        );

        if (!expanded) {
          // Horizontal scroller (2 visible at a time)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header('Show more…'),
              SizedBox(
                height: cardHeight,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPad,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: gap),
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return InkWell(
                      // Outer handler guarantees taps open the item page
                      onTap: onSelect == null ? null : () => onSelect!(p),
                      child: ProductCard(
                        product: p,
                        width: cardWidth,
                        height: cardHeight,
                        onTap: null, // avoid nested gesture conflicts
                        onAdd: null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }

        // Expanded inline grid
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
                  return InkWell(
                    onTap: onSelect == null ? null : () => onSelect!(p),
                    child: ProductCard(
                      product: p,
                      width: cardWidth,
                      height: cardHeight,
                      onTap: null,
                      onAdd: null,
                    ),
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
