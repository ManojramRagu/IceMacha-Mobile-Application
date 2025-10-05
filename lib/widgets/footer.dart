import 'package:flutter/material.dart';
import 'package:icemacha/theme.dart' show AppColors;

class Footer extends StatelessWidget {
  const Footer({super.key});

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
                  const _FooterCol(
                    title: 'Our Goal',
                    body:
                        'IceMacha brings you a curated selection of beverages, '
                        'snacks, and food items — fresh, convenient, and tasty.',
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
          ...listItems!.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Text('• ', style: TextStyle(color: Colors.white)),
                  Expanded(child: Text(t)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
