import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/utils/product.dart';
import 'package:icemacha/utils/cart_provider.dart';
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
    final inCart = cart.quantityFor(p.id);
    final remaining = cart.remainingFor(p.id);

    final title = p.title;
    final desc = p.description.trim().isNotEmpty
        ? p.description
        : 'A delicious $title made fresh for you.';

    void addToCart() {
      if (remaining <= 0) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Only 20 allowed per customer')),
          );
        return;
      }
      final want = _qty.clamp(1, remaining);
      final before = inCart;
      cart.add(p, qty: want);
      final after = cart.quantityFor(p.id);
      final capped =
          after == CartProvider.maxQty && before + want > CartProvider.maxQty;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              capped
                  ? 'Only ${CartProvider.maxQty} allowed per customer'
                  : 'Added $title (x$want)',
            ),
          ),
        );
    }

    // Keep local qty inside the latest remaining range
    final maxSelectable = remaining.clamp(0, CartProvider.maxQty);
    if (_qty > (maxSelectable == 0 ? 1 : maxSelectable)) {
      _qty = maxSelectable == 0 ? 1 : maxSelectable;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: cs.surface,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: cs.surfaceVariant),
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
          ),
          const SizedBox(height: 16),

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

          // Quantity + Add
          Row(
            children: [
              if (remaining > 0)
                QuantitySelector(
                  value: _qty,
                  min: 1,
                  max: remaining,
                  onChanged: (v) => setState(() => _qty = v),
                )
              else
                Text(
                  'Limit reached (${CartProvider.maxQty} per customer)',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              const Spacer(),
              SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
