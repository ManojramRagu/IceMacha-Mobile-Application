import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icemacha/models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, required this.qty});
  int get lineTotal => product.price * qty;

  // New getter for CartScreen
  String get imageUrl =>
      'https://d36bnb8wo21edh.cloudfront.net/${product.imagePath}';

  Map<String, dynamic> toJson() => {
    'productId': product.id,
    'title': product.title,
    'price': product.price,
    'quantity': qty,
    'imagePath': product.imagePath,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['productId'],
        title: json['title'],
        categoryPath: '', // Dummy
        price: json['price'],
        imagePath: json['imagePath'] ?? '', // Restored path
        description: '', // Dummy
        isPromotion: false, // Dummy
      ),
      qty: json['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  static const int minQty = 1;
  static const int maxQty = 20;

  final Map<String, CartItem> _items = {};

  CartProvider() {
    _loadFromDisk();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.values.map((item) => item.toJson()).toList();
    await prefs.setString('ice_macha_cart', jsonEncode(jsonList));
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('ice_macha_cart');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      _items.clear();
      for (final itemJson in decoded) {
        if (itemJson is Map<String, dynamic>) {
          final item = CartItem.fromJson(itemJson);
          _items[item.product.id] = item;
        }
      }
      notifyListeners();
    }
  }

  List<CartItem> get items => _items.values.toList(growable: false);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.length;
  int get totalQty => _items.values.fold(0, (s, i) => s + i.qty);
  int get subtotal => _items.values.fold(0, (s, i) => s + i.lineTotal);

  int quantityFor(String productId) => _items[productId]?.qty ?? 0;
  int remainingFor(String productId) =>
      (maxQty - quantityFor(productId)).clamp(0, maxQty);

  void add(Product p, {int qty = 1}) {
    final current = _items[p.id];
    if (current == null) {
      _items[p.id] = CartItem(product: p, qty: qty.clamp(minQty, maxQty));
    } else {
      current.qty = (current.qty + qty).clamp(minQty, maxQty);
    }
    notifyListeners();
    _saveToDisk();
  }

  void setQty(String productId, int qty) {
    final item = _items[productId];
    if (item == null) return;
    item.qty = qty.clamp(minQty, maxQty);
    notifyListeners();
    _saveToDisk();
  }

  void increment(String productId) =>
      setQty(productId, quantityFor(productId) + 1);

  void decrement(String productId) =>
      setQty(productId, quantityFor(productId) - 1);

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
    _saveToDisk();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveToDisk();
  }
}
