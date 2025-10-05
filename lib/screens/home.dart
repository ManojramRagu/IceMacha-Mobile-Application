import 'package:flutter/material.dart';
import 'package:icemacha/widgets/promo_carousel.dart';
import 'package:icemacha/theme.dart' show AppColors;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _hero = 'assets/img/hero/hero.webp';
  static const List<String> _promos = [
    'assets/img/products/Promotions/Coffee-Lovers.webp',
    'assets/img/products/Promotions/Festive-Treats.webp',
    'assets/img/products/Promotions/Healthy-Mornings.webp',
    'assets/img/products/Promotions/Midnight-Snacks.webp',
    'assets/img/products/Promotions/Summer-Coolers.webp',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Hero banner
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(_hero, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 20),

        // Intro
        Center(
          child: Text(
            'Delicious Moments\nDelivered to You',
            textAlign: TextAlign.center,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Welcome to IceMacha — your go-to destination for fresh, high-quality coffee, "
          "beverages, and snacks delivered to your door. Discover specials, combos, and seasonal offers.",
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(height: 1.4, color: cs.onBackground),
        ),
        const SizedBox(height: 20),

        // Promotions
        Text(
          'Promotions & Seasonal Offers',
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: const PromoCarousel(
            imagePaths: _promos,
            height: 160,
            dotsBelow: true,
          ),
        ),

        const SizedBox(height: 14),

        Align(
          alignment: Alignment.center,
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(minimumSize: const Size(140, 42)),
            child: const Text('Buy Now'),
          ),
        ),

        const SizedBox(height: 28),

        _Footer(),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.brown,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
      child: DefaultTextStyle(
        style: tt.bodySmall!.copyWith(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, c) {
                final isWide = c.maxWidth >= 360;
                final cols = [
                  _FooterCol(
                    title: 'Our Goal',
                    body:
                        "IceMacha brings you a curated selection of beverages, snacks, and food items — fresh, convenient, and tasty.",
                  ),
                  const _FooterCol(
                    title: 'Our Socials',
                    socials: [
                      Icons.camera_alt_outlined,
                      Icons.facebook_outlined,
                      Icons.alternate_email,
                    ],
                  ),
                  const _FooterCol(
                    title: 'Legal & Policies',
                    listItems: [
                      'Privacy Policy',
                      'Terms of Service',
                      'Refund Policy',
                    ],
                  ),
                ];

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cols[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cols[1]),
                      const SizedBox(width: 16),
                      Expanded(child: cols[2]),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cols[0],
                    const SizedBox(height: 16),
                    cols[1],
                    const SizedBox(height: 16),
                    cols[2],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: .85,
              child: Text(
                '© 2025 IceMacha. All rights reserved.',
                style: tt.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  final String title;
  final String? body;
  final List<IconData>? socials;
  final List<String>? listItems;

  const _FooterCol({
    required this.title,
    this.body,
    this.socials,
    this.listItems,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        if (body != null)
          Text(body!, style: tt.bodySmall?.copyWith(height: 1.4)),
        if (socials != null)
          Row(
            children: socials!
                .map(
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(i, color: Colors.white),
                  ),
                )
                .toList(),
          ),
        if (listItems != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listItems!
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: const [
                        Text('• ', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                )
                .toList()
                .asMap()
                .entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.white)),
                        Expanded(child: Text(listItems![e.key])),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
