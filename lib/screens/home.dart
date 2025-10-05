import 'package:flutter/material.dart';
import 'package:icemacha/widgets/promo_carousel.dart';

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
          "Welcome to IceMacha! your go to destination for fresh, high quality coffee, "
          "beverages, and snacks delivered to your door. Discover specials, combos, and seasonal offers.",
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(height: 1.4, color: cs.onSurface),
        ),
        const SizedBox(height: 20),

        // Promotions panel
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

        //Footer
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Goal',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  "IceMacha brings you a curated selection of beverages, snacks, and food items which are fresh, convenient, and tasty.",
                  style: tt.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
