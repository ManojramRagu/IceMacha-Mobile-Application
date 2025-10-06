import 'package:flutter/material.dart';
import 'package:icemacha/utils/product.dart';
import 'package:icemacha/widgets/product_card.dart';

class MenuSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final VoidCallback? onShowMore;
  final void Function(Product)? onSelect;

  const MenuSection({
    super.key,
    required this.title,
    required this.products,
    this.onShowMore,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, c) {
        final gap = 12.0;
        final horizontalPad = 16.0;
        final usable = c.maxWidth - (horizontalPad * 2) - gap;
        final cardWidth = usable / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPad, 8, horizontalPad, 6),
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
                  TextButton(
                    onPressed: onShowMore,
                    child: const Text('Show more'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: cardWidth + 118,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => SizedBox(width: gap),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return ProductCard(
                    product: p,
                    width: cardWidth,
                    onTap: onSelect == null ? null : () => onSelect!(p),
                    onAdd: null, // TODO: wire cart later
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
