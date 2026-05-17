import 'purchase_history_item.dart';

class PurchaseHistoryData {
  const PurchaseHistoryData({
    required this.profile,
    required this.name,
    required this.memberId,
    required this.avatarUrl,
    required this.pendingOrders,
    required this.lastPurchaseText,
    required this.purchases,
  });

  final Map<String, dynamic> profile;
  final String name;
  final String memberId;
  final String avatarUrl;
  final int pendingOrders;
  final String lastPurchaseText;
  final List<PurchaseHistoryItem> purchases;
}
