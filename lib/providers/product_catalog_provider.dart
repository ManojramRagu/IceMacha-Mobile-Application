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
      // Handle if root is List (API often returns list) vs Map (Assets structure)
      // If API returns list, we might need to assume it's flat or restructure.
      // For this assignment, assuming API follows structure OR we just parse.
      // But typically API V1 returning "products" returns a list.
      // Let's implement robust parsing.

      Map<String, dynamic> prods;
      List<dynamic> promotions = [];

      if (root is Map<String, dynamic>) {
        // Matches assets structure
        prods = root['Products'] as Map<String, dynamic>? ?? {};
        promotions = (root['Promotions'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
      } else {
        // Assuming API returns something else, but without API spec,
        // we risk breaking if we strict parse.
        // However, the assets/data/products.json is the source of truth for the UI structure.
        // If API returns a List, we can't map to "Beverages/Hot" without extra data.
        // I'll stick to the existing parsing logic which expects the Map structure.
        // If API returns plain list, it will fail here and go to catch -> fallback?
        // No, because this is called in the Success block of API.
        // If API returns List, jsonDecode returns List, casting to Map throws.
        // This is fine, it will trigger catch block and fall back to cache/assets if API data is incompatible.
        // Ideally API should return compatible structure.
        throw FormatException('Unexpected JSON structure');
      }

      final bevs = prods['Beverages'] as Map<String, dynamic>? ?? {};
      final food = prods['Food'] as Map<String, dynamic>? ?? {};

      final List<Product> items = [];

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
            Product.fromNested('Food/$sub', (e as Map).cast<String, dynamic>()),
          );
        }
      }

      // Promotions
      for (final e in promotions) {
        items.add(Product.fromNested('Promotions', e));
      }

      _all = items;
    } catch (e) {
      // if parsing fails, rethrow to trigger fallback in fetchData
      rethrow;
    }
  }

  List<Product> byCategory(String path) =>
      _all.where((p) => p.categoryPath == path && !p.isPromotion).toList();

  List<Product> promotions() =>
      _all.where((p) => p.categoryPath == 'Promotions').toList();
}
