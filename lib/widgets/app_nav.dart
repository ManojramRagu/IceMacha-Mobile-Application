import 'package:flutter/material.dart';

/// ================= TOP APP BAR =================
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, this.onLogoTap, this.onMenuTap});

  /// Tap logo → go Home (AppShell sets this).
  final VoidCallback? onLogoTap;

  /// Open the left drawer (AppShell provides this).
  final VoidCallback? onMenuTap;

  static const _logo = 'assets/img/logo.webp';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: onMenuTap,
      ),
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
                  Icon(Icons.local_cafe, color: cs.onPrimary),
            ),
          ),
        ),
      ),
      // No trailing actions on purpose.
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// ================= BOTTOM NAV BAR =================
/// Selected tab shows a filled pill using `colorScheme.primary` with
/// contrasting `onPrimary`. Labels always visible below icons.
/// Pass `currentIndex = -1` to show no selection (e.g., About/Contact).
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
            final icon = selected ? items[i].filled : items[i].outline;

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
                      Icon(
                        icon,
                        size: 26,
                        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                      ),
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
