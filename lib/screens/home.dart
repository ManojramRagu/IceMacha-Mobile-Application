import 'package:flutter/material.dart';
import 'package:icemacha/services/location_service.dart';
import 'package:icemacha/widgets/promo_carousel.dart';
import 'package:icemacha/core/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onBuyNow});

  final VoidCallback? onBuyNow;

  // Asset paths
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

    final wide = isWide(MediaQuery.sizeOf(context).width);

    Widget heroBanner() => ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(_hero, fit: BoxFit.cover),
      ),
    );

    Widget introAndPromos() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        FutureBuilder<double?>(
          future: LocationService().getDistanceToShop(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "You are ${snapshot.data!.toStringAsFixed(1)} km away from our Colombo outlet.",
                          style: tt.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 12),
        Text(
          "Welcome to IceMacha — your go-to destination for fresh, high-quality coffee, "
          "beverages, and snacks delivered to your door. Discover specials, combos, and seasonal offers.",
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(height: 1.4, color: cs.onSurface),
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
            onPressed: onBuyNow,
            style: FilledButton.styleFrom(minimumSize: const Size(140, 42)),
            child: const Text('Buy Now'),
          ),
        ),

        const SizedBox(height: 28),
      ],
    );

    if (wide) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heroBanner()),
            const SizedBox(width: 16),
            Expanded(child: SingleChildScrollView(child: introAndPromos())),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [heroBanner(), const SizedBox(height: 20), introAndPromos()],
    );
  }
}
