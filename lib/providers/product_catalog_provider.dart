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

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Sync: Try API
      if (kDebugMode) print('🔄 Fetching from API...');
      final jsonString = await _api.fetchProducts();

      // 2. Cache: Save to local storage
      await _storage.saveProducts(jsonString);
      if (kDebugMode) print('✅ API Success. Cached data.');

      // 3. Parse
      _parseAndLoad(jsonString);
    } catch (e) {
      if (kDebugMode) print('⚠️ API call failed: $e. Trying offline cache...');

      // 4. Offline: Try Cache
      final cached = await _storage.readProducts();
      if (cached != null && cached.isNotEmpty) {
        if (kDebugMode) print('📂 Loaded from Cache.');
        _parseAndLoad(cached);
      } else {
        // 5. Fallback: Assets
        if (kDebugMode) print('⚠️ Cache empty. Fallback to Assets.');
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
      if (kDebugMode) print('❌ Asset load error: $e');
    }
  }

  void _parseAndLoad(String rawJson) {
    try {
      final root = jsonDecode(rawJson);
      final List<Product> items = [];

      // Strategy A: Laravel Resource API (root['data'] is List)
      if (root is Map<String, dynamic> && root['data'] is List) {
        final list = root['data'] as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            // Helper to ensure categoryPath exists if missing
            if (item['categoryPath'] == null && item['category_path'] == null) {
              // Try to derive from image_path if category is missing
              final path = (item['imagePath'] ?? item['image_path'] ?? '')
                  .toString();
              final parts = path.split('/');
              if (parts.length >= 3 && parts[2] == 'Promotions') {
                item['categoryPath'] = 'Promotions';
                item['isPromotion'] = true;
              } else if (parts.length >= 4) {
                item['categoryPath'] = '${parts[2]}/${parts[3]}';
              }
            }
            items.add(Product.fromJson(item));
          }
        }

        if (items.isNotEmpty) {
          _all = items;
          notifyListeners();
          return;
        }
      }

      // Strategy B: Legacy Asset Map Structure
      if (root is Map<String, dynamic> && root.containsKey('Products')) {
        final prods = root['Products'] as Map<String, dynamic>? ?? {};
        final promotions = (root['Promotions'] as List<dynamic>? ?? []);

        final bevs = prods['Beverages'] as Map<String, dynamic>? ?? {};
        final food = prods['Food'] as Map<String, dynamic>? ?? {};

        void addFromList(List<dynamic>? list, String catPath) {
          if (list == null) return;
          for (final e in list) {
            if (e is Map<String, dynamic>) {
              items.add(Product.fromNested(catPath, e));
            }
          }
        }

        addFromList(bevs['Hot'] as List?, 'Beverages/Hot');
        addFromList(bevs['Cold'] as List?, 'Beverages/Cold');

        const foodSubs = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Desserts'];
        for (final sub in foodSubs) {
          addFromList(food[sub] as List?, 'Food/$sub');
        }

        for (final e in promotions) {
          if (e is Map<String, dynamic>) {
            items.add(Product.fromNested('Promotions', e));
          }
        }

        if (items.isNotEmpty) {
          _all = items;
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Parse error: $e');
      // Don't rethrow, strictly, to avoid crashing UI, just show empty or previous state
    }
  }

  List<Product> byCategory(String path) =>
      _all.where((p) => p.categoryPath == path && !p.isPromotion).toList();

  List<Product> promotions() =>
      _all.where((p) => p.categoryPath == 'Promotions').toList();
}
