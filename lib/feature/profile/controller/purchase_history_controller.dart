import 'package:dio/dio.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../model/purchase_history_data.dart';
import '../model/purchase_history_item.dart';

class PurchaseHistoryController {
  PurchaseHistoryController({
    UserApiService? userApi,
    TrainingShopApiService? api,
  }) : _userApi = userApi ?? UserApiService(),
       _api = api ?? TrainingShopApiService();

  final UserApiService _userApi;
  final TrainingShopApiService _api;

  Future<PurchaseHistoryData> loadData() async {
    final profileRes = await _userApi.getProfile();
    final historyRes = await _api.getPurchaseHistory();

    final profileRaw = profileRes['data'];
    final historyRaw = historyRes['data'];
    final profile = profileRaw is Map
        ? Map<String, dynamic>.from(profileRaw)
        : <String, dynamic>{};
    final data = historyRaw is Map
        ? Map<String, dynamic>.from(historyRaw)
        : <String, dynamic>{};
    final pendingOrders = (data['pendingOrders'] as num?)?.toInt() ?? 0;
    final lastPurchaseAt = (data['lastPurchaseAt'] ?? '').toString();
    final purchasesRaw = data['purchases'];

    final purchaseMaps = purchasesRaw is List
        ? purchasesRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : <Map<String, dynamic>>[];

    final purchases = purchaseMaps.map(_mapItem).toList();

    return PurchaseHistoryData(
      profile: profile,
      name: _toTitleCase((profile['name'] ?? 'Member').toString()),
      memberId: (profile['_id'] ?? '').toString(),
      avatarUrl: ((profile['avatar'] is Map
                  ? (profile['avatar'] as Map)['url']
                  : null) ??
              '')
          .toString(),
      pendingOrders: pendingOrders,
      lastPurchaseText: _formatDate(lastPurchaseAt),
      purchases: purchases,
    );
  }

  String parseError(Object error) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map && payload['message'] != null) {
        return payload['message'].toString();
      }
      if (payload is Map && payload['error'] != null) {
        return payload['error'].toString();
      }
    }
    return 'Failed to load purchase history';
  }

  String toPrice(double value) {
    if (value == value.roundToDouble()) return '\$${value.toStringAsFixed(0)}';
    return '\$${value.toStringAsFixed(2)}';
  }

  String statusLabel(String rawStatus) {
    final normalized = rawStatus.toLowerCase();
    if (normalized.contains('deliver')) return 'Delivered';
    if (normalized.contains('ship') ||
        normalized.contains('send') ||
        normalized.contains('dispatch')) {
      return 'Sent';
    }
    if (normalized.contains('process')) return 'Processing';
    if (normalized.contains('cancel')) return 'Canceled';
    return 'Pending';
  }

  PurchaseHistoryItem _mapItem(Map<String, dynamic> raw) {
    final status = _resolveStatus(raw);
    return PurchaseHistoryItem(
      raw: raw,
      orderId: _resolveOrderId(raw),
      title: _resolveTitle(raw),
      price: _resolvePrice(raw),
      imageUrl: _resolveImageUrl(raw),
      status: status,
      purchaseDate: _resolvePurchaseDate(raw),
      quantity: _resolveQuantity(raw),
      shippingAddress: _resolveShippingAddress(raw),
    );
  }

  String _formatDate(String raw, {String fallback = 'No purchase yet'}) {
    if (raw.trim().isEmpty) return fallback;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return fallback;
    const months = <String>[
      'January','February','March','April','May','June','July','August','September','October','November','December',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _firstNonEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  String _toTitleCase(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Member';
    return parts
        .map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _resolveOrderId(Map<String, dynamic> item) {
    final order = _asMap(item['order']);
    return _firstNonEmpty([
      item['orderId'], item['_id'], order['orderId'], order['_id'], order['id'],
    ], fallback: 'N/A');
  }

  String _resolveTitle(Map<String, dynamic> item) {
    final product = _asMap(item['product']);
    return _firstNonEmpty([
      item['title'], item['name'], item['productName'], product['name'], product['title'],
    ], fallback: 'Product');
  }

  double _resolvePrice(Map<String, dynamic> item) {
    final product = _asMap(item['product']);
    final values = [
      item['price'], item['amount'], item['total'], item['totalPrice'], item['unitPrice'], product['price'],
    ];
    for (final value in values) {
      final parsed = value is num ? value.toDouble() : double.tryParse((value ?? '').toString());
      if (parsed != null && parsed >= 0) return parsed;
    }
    return 0;
  }

  String _resolveImageUrl(Map<String, dynamic> item) {
    final product = _asMap(item['product']);
    final imageValue =
        item['imageUrl'] ?? item['image'] ?? product['imageUrl'] ?? product['thumbnail'] ?? product['image'];

    if (imageValue is List && imageValue.isNotEmpty) {
      final first = imageValue.first;
      if (first is Map) {
        final url = first['url']?.toString().trim() ?? '';
        if (url.isNotEmpty) return url;
      }
      final direct = first.toString().trim();
      if (direct.isNotEmpty) return direct;
    }
    if (imageValue is Map) {
      final url = imageValue['url']?.toString().trim() ?? '';
      if (url.isNotEmpty) return url;
    }
    return imageValue?.toString().trim() ?? '';
  }

  int _resolveQuantity(Map<String, dynamic> item) {
    final values = [item['quantity'], item['qty'], item['count']];
    for (final value in values) {
      final parsed = value is num ? value.toInt() : int.tryParse((value ?? '').toString());
      if (parsed != null && parsed > 0) return parsed;
    }
    return 1;
  }

  String _resolveStatus(Map<String, dynamic> item) {
    final order = _asMap(item['order']);
    final raw = _firstNonEmpty([
      item['status'], item['orderStatus'], item['deliveryStatus'], order['status'], order['orderStatus'], order['deliveryStatus'],
    ], fallback: 'pending').toLowerCase();
    return statusLabel(raw);
  }

  String _resolvePurchaseDate(Map<String, dynamic> item) {
    final order = _asMap(item['order']);
    final raw = _firstNonEmpty([
      item['purchasedAt'], item['purchaseDate'], item['createdAt'], item['date'], order['purchasedAt'], order['createdAt'], order['date'],
    ]);
    return _formatDate(raw, fallback: 'N/A');
  }

  String _resolveShippingAddress(Map<String, dynamic> item) {
    final order = _asMap(item['order']);
    return _firstNonEmpty([
      item['shippingAddress'], item['address'], order['shippingAddress'], order['address'],
    ], fallback: 'N/A');
  }
}
