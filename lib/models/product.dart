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

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] as String,
    title: j['title'] as String,
    categoryPath: j['categoryPath'] as String,
    price: (j['price'] as num).round(),
    imagePath: j['imagePath'] as String,
    description: (j['description'] as String?) ?? '',
    isPromotion: (j['isPromotion'] as bool?) ?? false,
  );

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
