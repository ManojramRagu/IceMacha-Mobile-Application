import 'package:flutter/foundation.dart';
import 'package:icemacha/models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, required this.qty});
  int get lineTotal => product.price * qty;

  Map<String, dynamic> toJson() => {
    'productId': product.id,
    'title': product.title,
    'price': product.price,
    'quantity': qty,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['productId'],
        title: json['title'],
        categoryPath: '', // Dummy
        price: json['price'],
        imagePath: '', // Dummy
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
  }

  void setQty(String productId, int qty) {
    final item = _items[productId];
    if (item == null) return;
    item.qty = qty.clamp(minQty, maxQty);
    notifyListeners();
  }

  void increment(String productId) =>
      setQty(productId, quantityFor(productId) + 1);

  void decrement(String productId) =>
      setQty(productId, quantityFor(productId) - 1);

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
