class Product {
  final String id;
  final String title;
  final String categoryPath;
  final int price;
  final String imagePath;
  final String description;
  final bool isPromotion;

  const Product({
    required this.id,
    required this.title,
    required this.categoryPath,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.isPromotion,
  });

  String get imageUrl {
    if (imagePath.startsWith('http')) return imagePath;

    if (imagePath.startsWith('storage/') || imagePath.startsWith('img/')) {
      return 'https://d36bnb8wo21edh.cloudfront.net/$imagePath';
    }

    // Default fallback or if it doesn't match expected prefixes,
    // assuming it might be a relative path needing the domain or just return as is?
    // Given the prompt: "Example: img/products/xyz.webp becomes https://.../img/products/xyz.webp"
    // It implies we should prepend.
    return 'https://d36bnb8wo21edh.cloudfront.net/$imagePath';
  }

  factory Product.fromJson(Map<String, dynamic> j) {
    // Parse Price "LKR 500.00" -> 500
    int parsedPrice = 0;
    if (j['price'] != null) {
      final pStr = j['price']
          .toString()
          .replaceAll('LKR', '')
          .replaceAll(',', '')
          .trim();
      parsedPrice = double.tryParse(pStr)?.round() ?? 0;
    }

    return Product(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? j['name'] ?? 'Unknown').toString(),
      categoryPath: (j['categoryPath'] ?? 'Other').toString(),
      price: parsedPrice,
      imagePath: (j['imagePath'] ?? j['image_path'] ?? '').toString(),
      description: (j['description'] as String?) ?? '',
      isPromotion: (j['isPromotion'] as bool?) ?? false,
    );
  }

  factory Product.fromNested(String categoryPath, Map<String, dynamic> j) =>
      Product(
        id: j['id'] as String,
        title: j['title'] as String,
        categoryPath: categoryPath,
        price: (j['price'] as num).round(),
        imagePath: j['imagePath'] as String,
        description: (j['description'] as String?) ?? '',
        isPromotion: categoryPath == 'Promotions',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'categoryPath': categoryPath,
    'price': price,
    'imagePath': imagePath,
    'description': description,
    'isPromotion': isPromotion,
  };
}
