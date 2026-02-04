import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:icemacha/models/product.dart';
import 'package:icemacha/services/api_service.dart';
import 'package:icemacha/services/local_storage_service.dart';

class ProductCatalogProvider extends ChangeNotifier {
  bool _isLoading = true;
  List<Product> _all = [];

  final Set<String> _expanded = {};

  static const List<String> _preferredOrder = [
    'Beverages/Hot',
    'Beverages/Cold',
    'Food/Breakfast',
    'Food/Lunch',
    'Food/Dinner',
    'Food/Snacks',
    'Food/Desserts',
  ];

  static const Map<String, String> _titles = {
    'Beverages/Hot': 'Hot Drinks',
    'Beverages/Cold': 'Cold Drinks',
    'Food/Breakfast': 'Breakfast',
    'Food/Lunch': 'Lunch',
    'Food/Dinner': 'Dinner',
    'Food/Snacks': 'Snacks',
    'Food/Desserts': 'Desserts',
    'Promotions': 'Promotions',
  };

  bool get isLoading => _isLoading;
  List<Product> get allProducts => _all;

  List<String> get categoryOrder =>
      _preferredOrder.where((p) => byCategory(p).isNotEmpty).toList();

  String titleFor(String path) => _titles[path] ?? path;

  bool isExpanded(String path) => _expanded.contains(path);
  void toggleExpanded(String path) {
    if (_expanded.contains(path)) {
      _expanded.remove(path);
    } else {
      _expanded.add(path);
    }
    notifyListeners();
  }

  final ApiService _api = ApiService();
  final LocalStorageService _storage = LocalStorageService();

  ProductCatalogProvider() {
    fetchData();
  }

  static const String _externalDataUrl =
      'https://d36bnb8wo21edh.cloudfront.net/api/v1/products';

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Sync: Fetch Main API
      final mainJsonString = await _api.fetchProducts();
      if (kDebugMode) print('✅ Loaded main products from API');

      Map<String, dynamic> mergedData;
      try {
        mergedData = jsonDecode(mainJsonString) as Map<String, dynamic>;
      } catch (e) {
        throw FormatException('Main API returned invalid JSON: $e');
      }

      // 2. Sync: Fetch External Data (Best Attempt)
      try {
        final externalJsonString = await _api.fetchExternalData(
          _externalDataUrl,
        );
        if (kDebugMode) print('✅ Loaded external data from URL');

        final externalData = jsonDecode(externalJsonString);
        if (externalData is Map<String, dynamic>) {
          _mergeExternalData(mergedData, externalData);
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ External data fetch failed: $e');
        // Continue with just main data
      }

      // Re-serialize for cache
      final combinedJsonString = jsonEncode(mergedData);

      // 3. Write: Cache merged data
      await _storage.saveJson(combinedJsonString);
      if (kDebugMode) print('💾 Cached merged products to local storage');

      // 4. Parse and Load
      _parseAndLoad(combinedJsonString);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ API load failed: $e. Trying cache...');
      }
      // 5. Read: Try Cache (which now contains merged data from previous runs)
      try {
        final cached = await _storage.readJson();
        if (cached != null && cached.isNotEmpty) {
          if (kDebugMode) print('📂 Loaded products from Local Cache');
          _parseAndLoad(cached);
        } else {
          // 6. Fallback: Assets
          if (kDebugMode) print('⚠️ Cache empty. Falling back to Assets');
          await _loadFromAssets();
        }
      } catch (e2) {
        if (kDebugMode) {
          print('⚠️ Cache load failed: $e2. Loading assets...');
        }
        await _loadFromAssets();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _mergeExternalData(
    Map<String, dynamic> main,
    Map<String, dynamic> external,
  ) {
    // Basic merge strategy:
    // Append external 'Promotions' to main 'Promotions'
    // Append external 'Products' sub-categories to main 'Products' sub-categories

    // 1. Merge Promotions
    if (external.containsKey('Promotions') && external['Promotions'] is List) {
      final mainPromos = (main['Promotions'] as List<dynamic>? ?? []);
      mainPromos.addAll(external['Promotions'] as List<dynamic>);
      main['Promotions'] = mainPromos;
    }

    // 2. Merge Products
    if (external.containsKey('Products') && external['Products'] is Map) {
      final extProds = external['Products'] as Map<String, dynamic>;
      final mainProds = main['Products'] as Map<String, dynamic>? ?? {};

      // Helper to merge categories (e.g., Beverages, Food)
      void mergeCategory(String catName) {
        if (extProds.containsKey(catName) && extProds[catName] is Map) {
          final extCat = extProds[catName] as Map<String, dynamic>;
          final mainCat = mainProds[catName] as Map<String, dynamic>? ?? {};

          for (final subCatKey in extCat.keys) {
            if (extCat[subCatKey] is List) {
              final mainSubList = (mainCat[subCatKey] as List<dynamic>? ?? []);
              mainSubList.addAll(extCat[subCatKey] as List<dynamic>);
              mainCat[subCatKey] = mainSubList;
            }
          }
          mainProds[catName] = mainCat;
        }
      }

      mergeCategory('Beverages');
      mergeCategory('Food');
      main['Products'] = mainProds;
    }
  }

  Future<void> _loadFromAssets() async {
    try {
      final raw = await rootBundle.loadString('assets/data/products.json');
      _parseAndLoad(raw);
    } catch (e) {
      _all = [];
      if (kDebugMode) {
        print('Asset load error: $e');
      }
    }
  }

  void _parseAndLoad(String rawJson) {
    try {
      final root = jsonDecode(rawJson);
      final List<Product> items = [];

      // 1. Handling API Response (Laravel Resource structure)
      if (root is Map<String, dynamic> &&
          root.containsKey('data') &&
          root['data'] is List) {
        final list = root['data'] as List;
        for (final item in list) {
          if (item is Map) {
            // "image_path": "img/products/Beverages/Hot/Americano.webp"
            final imagePath = item['image_path'] as String? ?? '';
            final parts = imagePath.split('/');

            String catPath = 'Other';
            bool isPromo = false;

            // Check if it's a promotion
            if (parts.length >= 3 && parts[2] == 'Promotions') {
              catPath = 'Promotions';
              isPromo = true;
            }
            // Check for standard Category/SubCategory structure
            else if (parts.length >= 4) {
              catPath = '${parts[2]}/${parts[3]}';
            }

            // Parse Price "LKR 500.00" -> 500
            int price = 0;
            if (item['price'] != null) {
              final pStr = item['price']
                  .toString()
                  .replaceAll('LKR', '')
                  .replaceAll(',', '')
                  .trim();
              price = double.tryParse(pStr)?.round() ?? 0;
            }

            items.add(
              Product(
                id: item['id'].toString(),
                title: item['name'] as String? ?? 'Unknown',
                categoryPath: catPath,
                price: price,
                imagePath: imagePath,
                description: item['description'] as String? ?? '',
                isPromotion: isPromo,
              ),
            );
          }
        }

        // If API returned items, use them
        if (items.isNotEmpty) {
          _all = items;
          notifyListeners();
          return;
        }
      }

      // 2. Handling Assets Response (Legacy Map structure)
      if (root is Map<String, dynamic>) {
        Map<String, dynamic> prods = {};
        List<dynamic> promotions = [];

        if (root.containsKey('Products')) {
          prods = root['Products'] as Map<String, dynamic>? ?? {};
          promotions = (root['Promotions'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();
        }

        // Only parse if we found the structure, otherwise loop will be empty
        // ... (Existing parsing logic) ...

        final bevs = prods['Beverages'] as Map<String, dynamic>? ?? {};
        final food = prods['Food'] as Map<String, dynamic>? ?? {};

        // Beverages
        for (final e in (bevs['Hot'] as List<dynamic>? ?? [])) {
          items.add(
            Product.fromNested(
              'Beverages/Hot',
              (e as Map).cast<String, dynamic>(),
            ),
          );
        }
        for (final e in (bevs['Cold'] as List<dynamic>? ?? [])) {
          items.add(
            Product.fromNested(
              'Beverages/Cold',
              (e as Map).cast<String, dynamic>(),
            ),
          );
        }

        // Food
        const foodSubs = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Desserts'];
        for (final sub in foodSubs) {
          for (final e in (food[sub] as List<dynamic>? ?? [])) {
            items.add(
              Product.fromNested(
                'Food/$sub',
                (e as Map).cast<String, dynamic>(),
              ),
            );
          }
        }

        // Promotions
        for (final e in promotions) {
          items.add(Product.fromNested('Promotions', e));
        }

        // If we found items using this method, update _all.
        // Even if empty, if the structure matched, we might set it to empty.
        // But for safety, let's strictly set if items found OR if we explicitly read assets.
        // Actually, if falling back to assets and assets are empty, allow empty.
        if (items.isNotEmpty || root.containsKey('Products')) {
          _all = items;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Parse error: $e');
      rethrow;
    }
  }

  List<Product> byCategory(String path) =>
      _all.where((p) => p.categoryPath == path && !p.isPromotion).toList();

  List<Product> promotions() =>
      _all.where((p) => p.categoryPath == 'Promotions').toList();
}
