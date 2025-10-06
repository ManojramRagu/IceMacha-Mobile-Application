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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isPromos = categoryPath == 'Promotions';
    final items = isPromos
        ? catalog.promotions()
        : catalog.byCategory(categoryPath);
    final title = isPromos
        ? 'All Promotions'
        : 'All — ${catalog.titleFor(categoryPath)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              title,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, c) {
              final gap = 12.0;
              final cols = 2;
              final totalGap = gap * (cols - 1);
              final cardWidth = (c.maxWidth - totalGap) / cols;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: items.map((p) {
                  return ProductCard(
                    product: p,
                    width: cardWidth,
                    onTap: null, // TODO: open item page later
                    onAdd: null, // TODO: cart later
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
