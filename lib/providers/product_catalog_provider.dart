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

  // Complete category list to ensure Food and Snacks are shown
  static const List<String> _preferredOrder = [
    'Beverages/Hot',
    'Beverages/Cold',
    'Food/Breakfast',
    'Food/Lunch',
    'Food/Dinner',
    'Food/Snacks',
    'Food/Desserts',
    'Promotions',
  ];

  static const Map<String, String> _titles = {
    'Beverages/Hot': 'Hot Drinks',
    'Beverages/Cold': 'Cold Drinks',
    'Food/Breakfast': 'Breakfast',
    'Food/Lunch': 'Lunch',
    'Food/Dinner': 'Dinner',
    'Food/Snacks': 'Snacks',
    'Food/Desserts': 'Desserts',
    'Promotions': 'Special Offers',
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

  /// Tiered Data Fetching: API (RDS) -> Local Cache (JSON) -> Assets
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Sync: Try V1 API (CloudFront)
      if (kDebugMode) print('🔄 Fetching full catalog from AWS RDS...');
      final jsonString = await _api.fetchProducts();

      // 2. Cache: WRITE the dynamic data to satisfy Section 3
      await _storage.saveProducts(jsonString);

      // 3. Parse and Load
      _parseAndLoad(jsonString);
    } catch (e) {
      if (kDebugMode)
        print('⚠️ API sync failed: $e. Accessing local data source...');

      // 4. Offline: READ from local storage
      final cached = await _storage.readProducts();
      if (cached != null && cached.isNotEmpty) {
        _parseAndLoad(cached);
      } else {
        // 5. Fallback: Bundled Assets
        await _loadFromAssets();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromAssets() async {
    try {
      final raw = await rootBundle.loadString('assets/data/products.json');
      _parseAndLoad(raw);
    } catch (e) {
      _all = [];
    }
  }

  void _parseAndLoad(String rawJson) {
    try {
      final root = jsonDecode(rawJson);
      final List<Product> items = [];

      // Logic for Laravel Resource API (root['data'] is the source)
      if (root is Map<String, dynamic> && root['data'] is List) {
        final list = root['data'] as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            _injectCategoryMetadata(item);
            items.add(Product.fromJson(item));
          }
        }
      }
      // Logic for Legacy Asset Structure
      else if (root is Map<String, dynamic> && root.containsKey('Products')) {
        _handleLegacyParsing(root, items);
      }

      if (items.isNotEmpty) {
        _all = items; // Update with the fresh list of 52 items
      }
    } catch (e) {
      if (kDebugMode) print('❌ Parse error: $e');
    }
  }

  /// Injects categoryPath into RDS items based on image_path folders
  void _injectCategoryMetadata(Map<String, dynamic> item) {
    if (item['categoryPath'] == null) {
      final path = (item['image_path'] ?? '').toString();
      final parts = path.split('/');

      if (path.contains('Promotions')) {
        item['categoryPath'] = 'Promotions';
        item['isPromotion'] = true;
      } else if (parts.length >= 4) {
        // Correctly maps 'img/products/Food/Breakfast/...' to 'Food/Breakfast'
        item['categoryPath'] = '${parts[2]}/${parts[3]}';
      } else {
        // Fallback for items with shallow paths like 'storage/products/default.jpg'
        item['categoryPath'] = (item['category_id'] == 2)
            ? 'Food/Snacks'
            : 'Beverages/Cold';
      }
    }
  }

  void _handleLegacyParsing(Map<String, dynamic> root, List<Product> items) {
    final prods = root['Products'] as Map<String, dynamic>? ?? {};
    final promotionsList = (root['Promotions'] as List<dynamic>? ?? []);

    void add(List<dynamic>? list, String cat) {
      if (list == null) return;
      for (final e in list) {
        if (e is Map<String, dynamic>) items.add(Product.fromNested(cat, e));
      }
    }

    add(prods['Beverages']?['Hot'], 'Beverages/Hot');
    add(prods['Beverages']?['Cold'], 'Beverages/Cold');
    for (var sub in ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Desserts']) {
      add(prods['Food']?[sub], 'Food/$sub');
    }
    for (var e in promotionsList) {
      if (e is Map<String, dynamic>)
        items.add(Product.fromNested('Promotions', e));
    }
  }

  /// Corrected logic to prevent infinite recursion and duplicate keys
  List<Product> byCategory(String path) {
    return _all.where((p) => p.categoryPath == path).toList();
  }

  List<Product> promotions() => _all
      .where((p) => p.categoryPath == 'Promotions' || p.isPromotion)
      .toList();
}
