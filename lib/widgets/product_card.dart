import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icemacha/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.width,
    this.height,
    this.onTap,
    this.onAdd,
  });

  static const double _contentHeight = 156;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final cardHeight = height ?? (width + _contentHeight);

    return Material(
      color: cs.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // square image area
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: width,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: cs.surfaceContainerHighest,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      // Fallback logic
                      var assetPath = product.imagePath;
                      if (!assetPath.startsWith('assets/')) {
                        // Assuming legacy or new paths are relative to assets/img if not absolute
                        // Note: For 'products/...' paths, this becomes 'assets/img/products/...' which likely matches local structure.
                        assetPath = 'assets/img/$assetPath';
                      }

                      return Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          // Ultimate fallback if even asset is missing
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              // content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'LKR ${product.price}',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add to Cart'),
                          onPressed: onAdd,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
