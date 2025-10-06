import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:icemacha/utils/product_catalog_provider.dart';
import 'package:icemacha/widgets/menu_section.dart';
import 'package:icemacha/widgets/promo_carousel.dart';
import 'package:icemacha/widgets/footer.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalogProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final promos = catalog.promotions();

    // Helper: group heading between Beverages and Food (match mockup)
    String? lastGroup;

    List<Widget> buildSections() {
      final widgets = <Widget>[];

      for (final path in catalog.categoryOrder) {
        final group = path.split('/').first; // "Beverages" or "Food"
        if (group != lastGroup) {
          lastGroup = group;
          widgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Text(
                group,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ),
          );
        }

        final products = catalog.byCategory(path);
        widgets.add(
          MenuSection(
            key: ValueKey(path),
            title: catalog.titleFor(path),
            products: products,
            expanded: catalog.isExpanded(path),
            onToggleExpand: () => catalog.toggleExpanded(path),
            onSelect: (_) {
              // TODO: open item page inside shell
            },
          ),
        );
      }

      return widgets;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero banner (optional)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/img/hero/hero.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Menu',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // All category sections
          ...buildSections(),

          // Promotions (guard if empty)
          if (promos.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  Text(
                    'Promotions',
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => catalog.toggleExpanded('Promotions'),
                    child: Text(
                      catalog.isExpanded('Promotions') ? 'Close' : 'Show more',
                    ),
                  ),
                ],
              ),
            ),

            if (!catalog.isExpanded('Promotions'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PromoCarousel(
                  imagePaths: promos.map((p) => p.imagePath).toList(),
                  height: 210,
                  dotsBelow: true,
                  interval: const Duration(seconds: 4),
                  slideDuration: const Duration(milliseconds: 350),
                  onTapSlide: (i) {
                    // TODO: open item page promos[i]
                  },
                  overlayBuilder: (ctx, i) {
                    final p = promos[i];
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('LKR ${p.price}', style: tt.titleMedium),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () {
                            // TODO: add to cart p
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add'),
                        ),
                      ],
                    );
                  },
                ),
              )
            else
              // Expanded Promotions: simple 2-up grid inline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, c) {
                    const gap = 12.0;
                    const cols = 2;
                    final cardWidth = (c.maxWidth - gap * (cols - 1)) / cols;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: promos.map((p) {
                        return SizedBox(
                          width: cardWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(
                                    p.imagePath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(p.title, style: tt.titleMedium),
                              const SizedBox(height: 2),
                              Text(
                                'LKR ${p.price}',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add_shopping_cart),
                                  label: const Text('Add'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
          ],

          const SizedBox(height: 24),
          const Footer(),
        ],
      ),
    );
  }
}
