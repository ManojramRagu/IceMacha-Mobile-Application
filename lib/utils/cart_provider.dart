import 'package:flutter/foundation.dart';
import 'package:icemacha/utils/product.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, required this.qty});

  int get lineTotal => product.price * qty;
}

class CartProvider extends ChangeNotifier {
  static const int minQty = 1;
  static const int maxQty = 10;

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.length; // distinct items
  int get totalQty => _items.values.fold(0, (s, i) => s + i.qty);
  int get subtotal => _items.values.fold(0, (s, i) => s + i.lineTotal);

  void add(Product p, {int qty = 1}) {
    final cur = _items[p.id];
    if (cur == null) {
      _items[p.id] = CartItem(product: p, qty: qty.clamp(minQty, maxQty));
    } else {
      cur.qty = (cur.qty + qty).clamp(minQty, maxQty);
    }
    notifyListeners();
  }

  void setQty(String productId, int qty) {
    final item = _items[productId];
    if (item == null) return;
    final v = qty.clamp(minQty, maxQty);
    item.qty = v;
    notifyListeners();
  }

  void increment(String productId) =>
      setQty(productId, (_items[productId]?.qty ?? 0) + 1);

  void decrement(String productId) =>
      setQty(productId, (_items[productId]?.qty ?? 0) - 1);

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
