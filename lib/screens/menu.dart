import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/models/product.dart';
import 'package:icemacha/providers/product_catalog_provider.dart';
import 'package:icemacha/providers/cart_provider.dart';
import 'package:icemacha/widgets/menu_section.dart';
import 'package:icemacha/screens/item.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure data is fetched when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCatalogProvider>().fetchData();
    });
  }

  void _openItem(BuildContext context, Product p) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ItemScreen(product: p)));
  }

  void _addToCart(BuildContext context, Product p) {
    final cart = context.read<CartProvider>();
    final before = cart.quantityFor(p.id);
    final left = CartProvider.maxQty - before;

    if (left <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Only ${CartProvider.maxQty} allowed per customer'),
          ),
        );
      return;
    }

    cart.add(p, qty: 1);
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
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.tertiary,
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
            onAdd: (p) => _addToCart(context, p),
          ),
        );
      }
      return widgets;
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ProductCatalogProvider>().fetchData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/img/hero/menu.webp',
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

            if (promos.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Text(
                  'Promotions',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.tertiary,
                  ),
                ),
              ),
              MenuSection(
                key: const ValueKey('Promotions'),
                title: 'Limited',
                products: promos,
                expanded: catalog.isExpanded('Promotions'),
                onToggleExpand: () => catalog.toggleExpanded('Promotions'),
                onSelect: (p) => _openItem(context, p),
                onAdd: (p) => _addToCart(context, p),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
