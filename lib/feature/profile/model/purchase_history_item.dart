class PurchaseHistoryItem {
  const PurchaseHistoryItem({
    required this.raw,
    required this.orderId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.purchaseDate,
    required this.quantity,
    required this.shippingAddress,
  });

  final Map<String, dynamic> raw;
  final String orderId;
  final String title;
  final double price;
  final String imageUrl;
  final String status;
  final String purchaseDate;
  final int quantity;
  final String shippingAddress;
}
