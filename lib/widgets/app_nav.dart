import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/providers/cart_provider.dart';

// TOP NAVIGATION BAR
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, this.onLogoTap});

  final VoidCallback? onLogoTap;

  static const _logo = 'assets/img/logo.webp';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      // Back arrow appears automatically
      centerTitle: true,
      title: GestureDetector(
        onTap: onLogoTap,
        child: ClipOval(
          child: Container(
            width: 32,
            height: 32,
            color: Colors.white.withValues(alpha: 0.9),
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              _logo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.local_cafe, color: cs.onSurface),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// BOTTOM NAVIGATION
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const items = <_NavItem>[
      _NavItem('Home', Icons.home_outlined, Icons.home),
      _NavItem('Menu', Icons.menu_book_outlined, Icons.menu_book),
      _NavItem('Cart', Icons.shopping_cart_outlined, Icons.shopping_cart),
      _NavItem('Profile', Icons.person_outline, Icons.person),
    ];

    final qty = context.select<CartProvider, int>((c) => c.totalQty);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            final iconData = selected ? items[i].filled : items[i].outline;
            final iconColor = selected ? cs.onPrimary : cs.onSurfaceVariant;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (items[i].label == 'Cart')
                        _CartIconWithBadge(
                          icon: iconData,
                          color: iconColor,
                          count: qty,
                        )
                      else
                        Icon(iconData, size: 26, color: iconColor),
                      const SizedBox(height: 6),
                      Text(
                        items[i].label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData outline;
  final IconData filled;
  const _NavItem(this.label, this.outline, this.filled);
}

class _CartIconWithBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;

  const _CartIconWithBadge({
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 26, color: color);

    if (count <= 0) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: -6,
          top: -6,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Container(
              key: ValueKey(count),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
