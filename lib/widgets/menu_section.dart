import 'package:flutter/material.dart';
import 'package:icemacha/utils/product.dart';
import 'package:icemacha/widgets/product_card.dart';

class MenuSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final bool expanded;
  final VoidCallback? onToggleExpand;
  final void Function(Product)? onSelect;
  final void Function(Product)? onAdd;

  const MenuSection({
    super.key,
    required this.title,
    required this.products,
    required this.expanded,
    this.onToggleExpand,
    this.onSelect,
    this.onAdd,
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

        // Collapsed sizing – 5 cards in landscape, 2 in portrait.
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final visibleCollapsed = isLandscape ? 5 : 2;
        final usableCollapsed =
            c.maxWidth - (horizontalPad * 2) - gap * (visibleCollapsed - 1);
        final cardWidthCollapsed = usableCollapsed / visibleCollapsed;
        const contentHeight = 156.0;
        final cardHeightCollapsed = cardWidthCollapsed + contentHeight;

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header('Show more…'),
              SizedBox(
                height: cardHeightCollapsed,
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
                      width: cardWidthCollapsed,
                      height: cardHeightCollapsed,
                      onTap: onSelect == null ? null : () => onSelect!(p),
                      onAdd: onAdd == null ? null : () => onAdd!(p),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }

        int columnsForWidth(double w) {
          if (w < 420) return 2;
          if (w < 600) return 3;
          if (w < 840) return 4;
          return 5;
        }

        final cols = columnsForWidth(c.maxWidth);
        final usableExpanded =
            c.maxWidth - (horizontalPad * 2) - gap * (cols - 1);
        final cardWidthExpanded = usableExpanded / cols;
        final cardHeightExpanded = cardWidthExpanded + contentHeight;

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
                    width: cardWidthExpanded,
                    height: cardHeightExpanded,
                    onTap: onSelect == null ? null : () => onSelect!(p),
                    onAdd: onAdd == null ? null : () => onAdd!(p),
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
