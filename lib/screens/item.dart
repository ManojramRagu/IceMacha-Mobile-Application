import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/models/product.dart';
import 'package:icemacha/providers/cart_provider.dart';
import 'package:icemacha/widgets/form.dart';

class ItemScreen extends StatefulWidget {
  final Product product;
  const ItemScreen({super.key, required this.product});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final tt = t.textTheme;

    final cart = context.watch<CartProvider>();
    final p = widget.product;

    final remaining = cart.remainingFor(p.id);
    final title = p.title;
    final desc = p.description.trim().isNotEmpty
        ? p.description
        : 'A delicious $title made fresh for you.';

    void addToCart() {
      final cartRW = context.read<CartProvider>();
      final inCartNow = cartRW.quantityFor(p.id);
      final remainingNow = CartProvider.maxQty - inCartNow;

      if (remainingNow <= 0) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Only ${CartProvider.maxQty} allowed per customer'),
            ),
          );
        return;
      }

      final want = _qty.clamp(1, remainingNow);
      cartRW.add(p, qty: want);

      final reachedCap =
          cartRW.quantityFor(p.id) == CartProvider.maxQty &&
          inCartNow + want > CartProvider.maxQty;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              reachedCap
                  ? 'Only ${CartProvider.maxQty} allowed per customer'
                  : 'Added $title (x$want)',
            ),
          ),
        );
    }

    final maxSelectable = remaining.clamp(0, CartProvider.maxQty);
    if (_qty > (maxSelectable == 0 ? 1 : maxSelectable)) {
      _qty = maxSelectable == 0 ? 1 : maxSelectable;
    }

    final details = <Widget>[
      Text(
        title,
        style: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
      const SizedBox(height: 8),
      Text(desc, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
      const SizedBox(height: 16),
      Text(
        'LKR ${p.price}',
        style: tt.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      const SizedBox(height: 12),
      if (remaining <= 0) ...[
        Text(
          'Limit reached (${CartProvider.maxQty} per customer)',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add to Cart'),
          ),
        ),
      ] else
        Row(
          children: [
            QuantitySelector(
              value: _qty,
              min: 1,
              max: remaining,
              onChanged: (v) => setState(() => _qty = v),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ),
            ),
          ],
        ),
    ];

    Widget imageCard({double aspect = 16 / 9}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: aspect,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: cs.surfaceContainerHighest),
              Image.asset(
                p.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.broken_image,
                    color: cs.onSurfaceVariant,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: cs.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          if (!isWide) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [imageCard(), const SizedBox(height: 16), ...details],
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: imageCard(aspect: 4 / 3)),
                const SizedBox(width: 16),
                Expanded(
                  flex: 7,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: details,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
