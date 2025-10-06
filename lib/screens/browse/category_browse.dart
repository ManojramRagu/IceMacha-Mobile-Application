import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/product_catalog_provider.dart';
import 'package:icemacha/widgets/product_card.dart';

class CategoryBrowse extends StatelessWidget {
  final String categoryPath;
  const CategoryBrowse({super.key, required this.categoryPath});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalogProvider>();
    // final cs = Theme.of(context).colorScheme;
    // final tt = Theme.of(context).textTheme;

    final isPromos = categoryPath == 'Promotions';
    final items = isPromos
        ? catalog.promotions()
        : catalog.byCategory(categoryPath);
    final title = isPromos
        ? 'All Promotions'
        : 'All — ${catalog.titleFor(categoryPath)}';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: LayoutBuilder(
          builder: (context, c) {
            final gap = 12.0;
            const cols = 2;
            final totalGap = gap * (cols - 1);
            final cardWidth = (c.maxWidth - totalGap) / cols;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: items.map((p) {
                return ProductCard(
                  product: p,
                  width: cardWidth,
                  onTap: () {
                    // TODO: open item page
                  },
                  onAdd: () {
                    // TODO: add to cart
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
