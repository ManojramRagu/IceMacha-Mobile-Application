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

  /// Dynamically resolves the image URL from CloudFront
  String get imageUrl {
    if (imagePath.isEmpty) return "";
    if (imagePath.startsWith('http')) return imagePath;

    // Base CloudFront domain
    const String baseUrl = "https://d36bnb8wo21edh.cloudfront.net";

    // Handles both 'img/products/...' and 'storage/products/...'
    final cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    return "$baseUrl/$cleanPath";
  }

  factory Product.fromJson(Map<String, dynamic> j) {
    // 1. Parse Price from "LKR 500.00" string
    int parsedPrice = 0;
    if (j['price'] != null) {
      // Regex strips "LKR" and spaces to leave "500.00"
      final pStr = j['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
      parsedPrice = double.tryParse(pStr)?.round() ?? 0;
    }

    // 2. Determine if it's a Promotion based on path or category_id
    // In your RDS, category_id 1 is Beverages, 2 is Food
    final path = (j['image_path'] ?? j['imagePath'] ?? '').toString();
    final bool promoStatus =
        (j['isPromotion'] as bool?) ?? path.contains('Promotions');

    return Product(
      id: (j['id'] ?? '').toString(),
      // Maps 'name' from RDS JSON to 'title' in the app
      title: (j['name'] ?? j['title'] ?? 'Unknown Item').toString(),
      // Maps 'category_id' to path if categoryPath is missing
      categoryPath:
          (j['categoryPath'] ?? (j['category_id'] == 2 ? 'Food' : 'Beverages'))
              .toString(),
      price: parsedPrice,
      imagePath: path,
      description: (j['description'] as String?) ?? '',
      isPromotion: promoStatus,
    );
  }

  // Maintains compatibility with your legacy local asset loading
  factory Product.fromNested(String categoryPath, Map<String, dynamic> j) =>
      Product(
        id: j['id'].toString(),
        title: (j['title'] ?? j['name'] ?? 'Unknown').toString(),
        categoryPath: categoryPath,
        price: (j['price'] is num)
            ? (j['price'] as num).round()
            : (double.tryParse(
                    j['price'].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                  )?.round() ??
                  0),
        imagePath: (j['imagePath'] ?? j['image_path'] ?? '').toString(),
        description: (j['description'] as String?) ?? '',
        isPromotion:
            categoryPath == 'Promotions' ||
            (j['isPromotion'] as bool? ?? false),
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
