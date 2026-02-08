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

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ProductCatalogProvider>().fetchData();
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/img/hero/menu.webp', fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search menu...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: cs.surface,
                ),
                onChanged: (value) {
                  context.read<ProductCatalogProvider>().updateSearchQuery(
                    value,
                  );
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final path = catalog.categoryOrder[index];
              final group = path.split('/').first;
              final isNewGroup =
                  index == 0 ||
                  catalog.categoryOrder[index - 1].split('/').first != group;

              final products = catalog.byCategory(path);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isNewGroup)
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
                  MenuSection(
                    key: ValueKey(path),
                    title: catalog.titleFor(path),
                    products: products,
                    expanded: catalog.isExpanded(path),
                    onToggleExpand: () => catalog.toggleExpanded(path),
                    onSelect: (p) => _openItem(context, p),
                    onAdd: (p) => _addToCart(context, p),
                  ),
                ],
              );
            }, childCount: catalog.categoryOrder.length),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}
