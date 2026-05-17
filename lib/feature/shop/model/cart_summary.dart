import 'cart_item_ui.dart';

class CartSummary {
  const CartSummary({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final List<CartItemUi> items;
  final double subtotal;
  final double tax;
  final double total;
}
