import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:icemacha/utils/product.dart';

class ProductCatalogProvider extends ChangeNotifier {
  bool _isLoading = true;
  List<Product> _all = [];
  String? showAllFor;

  static const List<String> _categoryOrder = [
    'Beverages/Hot',
    'Beverages/Cold',
    'Food/Breakfast',
    'Food/Lunch',
    'Food/Dinner',
    'Food/Snacks',
    'Food/Desserts',
  ];

  static const Map<String, String> _titles = {
    'Beverages/Hot': 'Hot Beverages',
    'Beverages/Cold': 'Cold Beverages',
    'Food/Breakfast': 'Breakfast',
    'Food/Lunch': 'Lunch',
    'Food/Dinner': 'Dinner',
    'Food/Snacks': 'Snacks',
    'Food/Desserts': 'Desserts',
    'Promotions': 'Promotions',
  };

  bool get isLoading => _isLoading;
  List<Product> get allProducts => _all;
  List<String> get categoryOrder => _categoryOrder;
  String titleFor(String path) => _titles[path] ?? path;

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

      const foodSubs = ['Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Desserts'];
      for (final sub in foodSubs) {
        for (final e in (food[sub] as List<dynamic>? ?? [])) {
          items.add(
            Product.fromNested('Food/$sub', (e as Map).cast<String, dynamic>()),
          );
        }
      }

      for (final e in promotions) {
        items.add(Product.fromNested('Promotions', e));
      }

      _all = items;
    } catch (e) {
      _all = [];
      if (kDebugMode) {
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

  void setShowAllFor(String? path) {
    showAllFor = path;
    notifyListeners();
  }
}
