import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/providers/product_catalog_provider.dart';
import 'package:icemacha/widgets/product_card.dart';

class CategoryBrowse extends StatelessWidget {
  final String categoryPath;
  const CategoryBrowse({super.key, required this.categoryPath});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalogProvider>();

    final isPromos = categoryPath == 'Promotions';
    final items = isPromos
        ? catalog.promotions()
        : catalog.byCategory(categoryPath);
    final title = isPromos
        ? 'All Promotions'
        : 'All — ${catalog.titleFor(categoryPath)}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LayoutBuilder(
        builder: (context, c) {
          const gap = 12.0;
          const cols = 2;
          final cardWidth = (c.maxWidth - gap * (cols - 1) - 16 * 2) / cols;
          const contentHeight = 124.0;
          final cardHeight = cardWidth + contentHeight;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: items.map((p) {
                return ProductCard(
                  product: p,
                  width: cardWidth,
                  height: cardHeight,
                  onTap: () {},
                  onAdd: () {},
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
