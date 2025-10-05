import 'package:flutter/material.dart';

// TOP NAVIGATION BAR
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  static const _logo = 'assets/img/logo.webp';

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
      centerTitle: true,
      title: SizedBox(
        height: 28,
        child: Image.asset(
          _logo,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(
            'IceMacha',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.shopping_cart_outlined),
        ),
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.person_outline),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// BOTTOM NAVIGATION BAR
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _base = 'assets/img/icons';
  static const _home = '$_base/home.png';
  static const _homeFilled = '$_base/home-filled.png';
  static const _menu = '$_base/menu.png';
  static const _menuFilled = '$_base/menu-filled.png';
  static const _cart = '$_base/cart.png';
  static const _cartFilled = '$_base/cart-filled.png';
  static const _account = '$_base/account.png';
  static const _accountFill = '$_base/account-filled.png';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = <_NavItem>[
      const _NavItem('Home', _home, _homeFilled),
      const _NavItem('Menu', _menu, _menuFilled),
      const _NavItem('Cart', _cart, _cartFilled),
      const _NavItem('Profile', _account, _accountFill),
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
            final iconPath = selected ? items[i].filled : items[i].outline;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: selected
                              ? Border.all(color: cs.primary, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          iconPath,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
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
                          color: selected ? cs.primary : cs.onSurfaceVariant,
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
  final String outline;
  final String filled;
  const _NavItem(this.label, this.outline, this.filled);
}
