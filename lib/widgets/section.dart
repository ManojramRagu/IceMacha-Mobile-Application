import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.title,
    required this.imagePath,
    required this.body,
    this.imageHeight = 150,
  });

  final String title;
  final String imagePath;
  final String body;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: cs.secondaryContainer),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(body, style: tt.bodyMedium?.copyWith(height: 1.5)),
      ],
    );
  }
}
