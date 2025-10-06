import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/product_catalog_provider.dart';
import 'package:icemacha/widgets/menu_section.dart';
import 'package:icemacha/widgets/promo_carousel.dart';
import 'package:icemacha/widgets/footer.dart';
import 'package:icemacha/screens/browse/category_browse.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  void _goShowMore(BuildContext context, String categoryPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryBrowse(categoryPath: categoryPath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalogProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (catalog.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final promos = catalog.promotions();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

          ...catalog.categoryOrder.map((path) {
            final products = catalog.byCategory(path);
            return MenuSection(
              key: ValueKey(path),
              title: catalog.titleFor(path),
              products: products,
              onShowMore: () => _goShowMore(context, path),
              onSelect: (_) {
                // TODO: open item page inside shell
              },
            );
          }),

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
                  onPressed: () => _goShowMore(context, 'Promotions'),
                  child: const Text('Show more'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PromoCarousel(
              imagePaths: promos.map((p) => p.imagePath).toList(),
              height: 210,
              dotsBelow: true,
              interval: const Duration(seconds: 4),
              slideDuration: const Duration(milliseconds: 350),

              // open item later
              onTapSlide: (i) {
                // TODO: open item page for promos[i]
              },

              overlayBuilder: (ctx, i) => Row(
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
                    child: Text(
                      'LKR ${promos[i].price}',
                      style: tt.titleMedium,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: add to cart promos[i]
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Footer(),
        ],
      ),
    );
  }
}
