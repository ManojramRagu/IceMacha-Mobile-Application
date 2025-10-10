import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/screens/checkout.dart';
import 'package:icemacha/utils/cart_provider.dart';
import 'package:icemacha/widgets/form.dart';
import 'package:icemacha/core/responsive.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onBrowseMenu;
  const CartScreen({super.key, this.onBrowseMenu});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text('Your cart is empty', style: tt.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Browse menu.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onBrowseMenu,
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Browse Menu'),
              ),
            ],
          ),
        ),
      );
    }

    final wide = isWide(MediaQuery.sizeOf(context).width);
    Widget itemCard(CartItem item) {
      final p = item.product;
      return Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: cs.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  p.imagePath,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // title + unit price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LKR ${p.price}',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // qty selector
              SizedBox(
                width: 140,
                child: QuantitySelector(
                  value: item.qty,
                  min: CartProvider.minQty,
                  max: CartProvider.maxQty,
                  onChanged: (v) =>
                      context.read<CartProvider>().setQty(p.id, v),
                ),
              ),
              const SizedBox(width: 8),

              // remove
              IconButton(
                tooltip: 'Remove',
                onPressed: () => context.read<CartProvider>().remove(p.id),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      );
    }

    Widget summaryBlock() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Subtotal', style: tt.titleMedium),
            const Spacer(),
            Text(
              'LKR ${cart.subtotal}',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Taxes, delivery & promotions are calculated at checkout.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Checkout')),
                  body: const CheckoutScreen(),
                ),
              ),
            );
          },
          icon: const Icon(Icons.payments),
          label: const Text('Checkout'),
        ),
      ],
    );

    if (wide) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left title + items
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'Your Cart',
                    style: tt.headlineSmall?.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: 12),
                  ...cart.items.map(itemCard),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right summary column
            SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // match divider spacing from original
                    const SizedBox(height: 8),
                    Divider(color: cs.outlineVariant),
                    const SizedBox(height: 8),
                    summaryBlock(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Your Cart', style: tt.headlineSmall?.copyWith(color: cs.primary)),
        const SizedBox(height: 12),

        // Items
        ...cart.items.map(itemCard),

        const SizedBox(height: 8),
        Divider(color: cs.outlineVariant),
        const SizedBox(height: 8),

        // Totals + Checkout
        summaryBlock(),
      ],
    );
  }
}
