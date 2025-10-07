import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/product.dart';
import 'package:icemacha/utils/product_catalog_provider.dart';
import 'package:icemacha/utils/cart_provider.dart';
import 'package:icemacha/widgets/menu_section.dart';
import 'package:icemacha/widgets/footer.dart';
import 'package:icemacha/screens/item.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _openItem(BuildContext context, Product p) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ItemScreen(product: p)));
  }

  void _addToCart(BuildContext context, Product p) {
    context.read<CartProvider>().add(p);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${p.title} added to cart')));
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

    String? lastGroup;
    List<Widget> buildSections() {
      final widgets = <Widget>[];
      for (final path in catalog.categoryOrder) {
        final group = path.split('/').first;
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
            onSelect: (p) => _openItem(context, p),
            onAdd: (p) => _addToCart(context, p), // <-- NEW
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

          ...buildSections(),

          if (promos.isNotEmpty)
            MenuSection(
              key: const ValueKey('Promotions'),
              title: 'Promotions & Seasonal Offers',
              products: promos,
              expanded: catalog.isExpanded('Promotions'),
              onToggleExpand: () => catalog.toggleExpanded('Promotions'),
              onSelect: (p) => _openItem(context, p),
              onAdd: (p) => _addToCart(context, p),
            ),

          const SizedBox(height: 24),
          const Footer(),
        ],
      ),
    );
  }
}
