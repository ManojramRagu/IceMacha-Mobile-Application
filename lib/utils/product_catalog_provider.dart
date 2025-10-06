import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:icemacha/utils/product.dart';

/// Loads assets/data/products.json (nested), flattens to Product list,
/// exposes helpers + "Show more" inline expansion state.
class ProductCatalogProvider extends ChangeNotifier {
  bool _isLoading = true;
  List<Product> _all = [];

  // Track which sections are expanded ("Show more")
  final Set<String> _expanded = {};

  // Preferred render order; empty sections are skipped automatically.
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

  /// Final order for Menu (skip empties).
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

  ProductCatalogProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/data/products.json');
      final root = jsonDecode(raw) as Map<String, dynamic>;

      final prods = root['Products'] as Map<String, dynamic>? ?? {};
      final bevs = prods['Beverages'] as Map<String, dynamic>? ?? {};
      final food = prods['Food'] as Map<String, dynamic>? ?? {};
      final promotions = (root['Promotions'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

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
      _all = [];
      if (kDebugMode) {
        // ignore: avoid_print
        print('Product catalog load error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> byCategory(String path) =>
      _all.where((p) => p.categoryPath == path && !p.isPromotion).toList();

  List<Product> promotions() =>
      _all.where((p) => p.categoryPath == 'Promotions').toList();
}
