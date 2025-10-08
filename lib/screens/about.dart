import 'package:flutter/material.dart';
import 'package:icemacha/widgets/app_nav.dart';
import 'package:icemacha/widgets/section.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _heroImg = 'assets/img/about/about-hero.webp';
  static const _storyImg = 'assets/img/about/story.webp';
  static const _commitImg = 'assets/img/about/commitment.webp';
  static const _visionImg = 'assets/img/about/vision.webp';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppTopBar(), // shows back arrow when pushed
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  _heroImg,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: cs.secondaryContainer,
                    alignment: Alignment.center,
                    child: Icon(Icons.local_cafe, size: 48, color: cs.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Center(
              child: Text(
                'About IceMacha',
                textAlign: TextAlign.center,
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              "We're dedicated to bringing you fresh coffee, beverages, and snacks with fast, friendly service. "
              "Here's a quick look at our story, our commitment, and our vision.",
              style: tt.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 18),

            Section(
              title: 'Our Story',
              imagePath: _storyImg,
              body:
                  "IceMacha started with a love for quality flavors and convenience. "
                  "From humble beginnings to your doorstep, we focus on taste, freshness, and a seamless experience.",
            ),
            const SizedBox(height: 16),

            Section(
              title: 'Our Commitment',
              imagePath: _commitImg,
              body:
                  "We choose quality ingredients and consistent preparation. "
                  "Every order is handled with care — your satisfaction is our priority.",
            ),
            const SizedBox(height: 16),

            Section(
              title: 'Our Vision',
              imagePath: _visionImg,
              body:
                  "We aim to make wholesome, delicious food and beverages accessible to everyone, anytime and anywhere "
                  "with technology, creativity, and great service.",
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
