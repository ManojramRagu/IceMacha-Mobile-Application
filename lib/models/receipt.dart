class OrderLineView {
  final String title;
  final int qty;
  final int unitPrice;
  const OrderLineView({
    required this.title,
    required this.qty,
    required this.unitPrice,
  });
}

class OrderReceipt {
  final String orderNo;
  final DateTime dateTime;
  final String paymentMethod;
  final String city;
  final List<OrderLineView> lines;
  final int total;
  const OrderReceipt({
    required this.orderNo,
    required this.dateTime,
    required this.paymentMethod,
    required this.city,
    required this.lines,
    required this.total,
  });
}
