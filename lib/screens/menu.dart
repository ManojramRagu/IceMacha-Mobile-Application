import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/product_catalog_provider.dart';
import 'package:icemacha/widgets/menu_section.dart';
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

    // Helper to group Beverages / Food headings like your mockup
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
          // Hero banner (matches your other pages)
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

          // All regular category sections
          ...buildSections(),

          // Promotions – now the SAME UX as other sections
          if (promos.isNotEmpty)
            MenuSection(
              key: const ValueKey('Promotions'),
              title: 'Promotions & Seasonal Offers',
              products: promos,
              expanded: catalog.isExpanded('Promotions'),
              onToggleExpand: () => catalog.toggleExpanded('Promotions'),
              onSelect: (_) {
                // TODO: open item page
              },
            ),

          const SizedBox(height: 24),
          const Footer(),
        ],
      ),
    );
  }
}
