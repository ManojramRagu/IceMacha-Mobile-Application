import 'package:flutter/material.dart';
import 'package:icemacha/widgets/app_menu.dart';

// TOP NAVIGATION BAR
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, this.onLogoTap});

  final VoidCallback? onLogoTap;

  static const _logo = 'assets/img/logo.webp';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: () => showAppMenu(context),
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

    const items = <_NavItem>[
      _NavItem('Home', _home, _homeFilled),
      _NavItem('Menu', _menu, _menuFilled),
      _NavItem('Cart', _cart, _cartFilled),
      _NavItem('Profile', _account, _accountFill),
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
                      Image.asset(iconPath, height: 26, fit: BoxFit.contain),
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
  final String outline;
  final String filled;
  const _NavItem(this.label, this.outline, this.filled);
}
