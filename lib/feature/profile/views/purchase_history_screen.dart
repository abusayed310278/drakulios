import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/common/widgets/page_loading_overlay.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final UserApiService _userApi = UserApiService();
  final TrainingShopApiService _api = TrainingShopApiService();

  bool _loading = true;
  Map<String, dynamic> _profile = const {};
  int _pendingOrders = 0;
  String _lastPurchaseText = 'No purchase yet';
  List<Map<String, dynamic>> _purchases = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profileRes = await _userApi.getProfile();
      final historyRes = await _api.getPurchaseHistory();

      final profile = Map<String, dynamic>.from(
        (profileRes['data'] ?? {}) as Map,
      );
      final data = Map<String, dynamic>.from((historyRes['data'] ?? {}) as Map);
      final pendingOrders = (data['pendingOrders'] as num?)?.toInt() ?? 0;
      final lastPurchaseAt = (data['lastPurchaseAt'] ?? '').toString();
      final purchasesRaw = data['purchases'];
      final purchases = purchasesRaw is List
          ? purchasesRaw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _pendingOrders = pendingOrders;
        _lastPurchaseText = _formatDate(lastPurchaseAt);
        _purchases = purchases;
      });
    } on DioException catch (e) {
      final payload = e.response?.data;
      final msg = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : payload is Map && payload['error'] != null
          ? payload['error'].toString()
          : 'Failed to load purchase history';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load purchase history');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String raw, {String fallback = 'No purchase yet'}) {
    if (raw.trim().isEmpty) return fallback;
    final dt = DateTime.tryParse(raw);
    if (dt == null) return fallback;
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
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

  String _toPrice(dynamic value) {
    final numValue = value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
    if (numValue == numValue.roundToDouble()) {
      return '\$${numValue.toStringAsFixed(0)}';
    }
    return '\$${numValue.toStringAsFixed(2)}';
  }

  String _toTitleCase(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Member';
    return parts
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _resolveOrderId(Map<String, dynamic> item) {
    final order = _asMap(item['order']);
    return _firstNonEmpty([
      item['orderId'],
      item['_id'],
      order['orderId'],
      order['_id'],
      order['id'],
    ], fallback: 'N/A');
  }

  String _resolveTitle(Map<String, dynamic> item) {
    final product = _asMap(item['product']);
    return _firstNonEmpty([
      item['title'],
      item['name'],
      item['productName'],
      product['name'],
      product['title'],
    ], fallback: 'Product');
  }

  double _resolvePrice(Map<String, dynamic> item) {
    final product = _asMap(item['product']);
    final values = [
      item['price'],
      item['amount'],
      item['total'],
      item['totalPrice'],
      item['unitPrice'],
      product['price'],
    ];
    for (final value in values) {
      final parsed = value is num
          ? value.toDouble()
          : double.tryParse((value ?? '').toString());
      if (parsed != null && parsed >= 0) return parsed;
    }
    return 0;
  }

  String _resolveImageUrl(Map<String, dynamic> item) {
    final product = _asMap(item['product']);
    final imageValue =
        item['imageUrl'] ??
        item['image'] ??
        product['imageUrl'] ??
        product['thumbnail'] ??
        product['image'];

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
      final parsed = value is num
          ? value.toInt()
          : int.tryParse((value ?? '').toString());
      if (parsed != null && parsed > 0) return parsed;
    }
    return 1;
  }

  String _resolveStatus(Map<String, dynamic> item) {
    final order = _asMap(item['order']);
    final raw = _firstNonEmpty([
      item['status'],
      item['orderStatus'],
      item['deliveryStatus'],
      order['status'],
      order['orderStatus'],
      order['deliveryStatus'],
    ], fallback: 'pending').toLowerCase();

    if (raw.contains('deliver')) return 'Delivered';
    if (raw.contains('ship') ||
        raw.contains('send') ||
        raw.contains('dispatch')) {
      return 'Sent';
    }
    if (raw.contains('process')) return 'Processing';
    if (raw.contains('cancel')) return 'Canceled';
    return 'Pending';
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'delivered') return const Color(0xFF3ECF8E);
    if (normalized == 'sent') return const Color(0xFF59B7FF);
    if (normalized == 'processing') return const Color(0xFFF3B41A);
    if (normalized == 'canceled') return const Color(0xFFFF7B7B);
    return const Color(0xFFE4A312);
  }

  String _resolvePurchaseDate(Map<String, dynamic> item) {
    final order = _asMap(item['order']);
    final raw = _firstNonEmpty([
      item['purchasedAt'],
      item['purchaseDate'],
      item['createdAt'],
      item['date'],
      order['purchasedAt'],
      order['createdAt'],
      order['date'],
    ]);
    return _formatDate(raw, fallback: 'N/A');
  }

  String _resolveShippingAddress(Map<String, dynamic> item) {
    final order = _asMap(item['order']);
    return _firstNonEmpty([
      item['shippingAddress'],
      item['address'],
      order['shippingAddress'],
      order['address'],
    ], fallback: 'N/A');
  }

  Future<void> _openPurchaseDetails(Map<String, dynamic> item) async {
    final orderId = _resolveOrderId(item);
    final title = _resolveTitle(item);
    final status = _resolveStatus(item);
    final purchaseDate = _resolvePurchaseDate(item);
    final price = _toPrice(_resolvePrice(item));
    final quantity = _resolveQuantity(item);
    final shippingAddress = _resolveShippingAddress(item);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF10151E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2D3747), width: 1),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Purchase Details',
                      style: TextStyle(
                        color: Color(0xFFF5F7FA),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _StatusBadge(label: status, color: _statusColor(status)),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailRow(label: 'Order ID', value: orderId),
                _DetailRow(label: 'Product', value: title),
                _DetailRow(label: 'Price', value: price),
                _DetailRow(label: 'Quantity', value: '$quantity'),
                _DetailRow(label: 'Purchase Date', value: purchaseDate),
                _DetailRow(label: 'Shipping Address', value: shippingAddress),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _toTitleCase((_profile['name'] ?? 'Member').toString());
    final memberId = (_profile['_id'] ?? '').toString();
    final avatarUrl = (_profile['avatar']?['url'] ?? '').toString();

    if (_loading && _profile.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF050608),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF3B41A)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_loading)
                        const LinearProgressIndicator(
                          minHeight: 1.5,
                          color: Color(0xFFF3B41A),
                          backgroundColor: Colors.transparent,
                        ),
                      Row(
                        children: [
                          Transform.translate(
                            offset: const Offset(-12, 0),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: Color(0xFFC9CDD3),
                              ),
                              splashRadius: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ),
                          Text(
                            'Purchase History',
                            style: GoogleFonts.outfit(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: const Color(0xFF2A2F39),
                            child: ClipOval(
                              child: avatarUrl.trim().isNotEmpty
                                  ? Image.network(
                                      avatarUrl,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                Images.profileImage,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                  : Image.asset(
                                      Images.profileImage,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Member ID : $memberId',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFD8DCE2),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Purchase Status',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StatusTile(text: 'Pending Orders: $_pendingOrders'),
                      const SizedBox(height: 8),
                      _StatusTile(text: 'Last Purchase: $_lastPurchaseText'),
                      const SizedBox(height: 14),
                      Text(
                        'Purchase List',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_purchases.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Center(
                            child: Text(
                              'No purchase history yet',
                              style: TextStyle(
                                color: Color(0xFF9AA1AE),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate(_purchases.length, (index) {
                          final item = _purchases[index];
                          final orderId = _resolveOrderId(item);
                          final title = _resolveTitle(item);
                          final price = _toPrice(_resolvePrice(item));
                          final imageUrl = _resolveImageUrl(item);
                          final status = _resolveStatus(item);
                          final purchaseDate = _resolvePurchaseDate(item);
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _purchases.length - 1 ? 0 : 10,
                            ),
                            child: _PurchaseCard(
                              orderId: orderId,
                              title: title,
                              price: price,
                              imageUrl: imageUrl,
                              status: status,
                              purchaseDate: purchaseDate,
                              onTap: () => _openPurchaseDetails(item),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                PageLoadingOverlay(loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E234D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2C6CFF), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_filled,
            color: Color(0xFFF3B41A),
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.outfit(
              color: const Color(0xFFF2F4F8),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.orderId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.purchaseDate,
    required this.onTap,
  });

  final String orderId;
  final String title;
  final String price;
  final String imageUrl;
  final String status;
  final String purchaseDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();
    final statusColor = normalizedStatus == 'delivered'
        ? const Color(0xFF3ECF8E)
        : normalizedStatus == 'sent'
        ? const Color(0xFF59B7FF)
        : normalizedStatus == 'processing'
        ? const Color(0xFFF3B41A)
        : normalizedStatus == 'canceled'
        ? const Color(0xFFFF7B7B)
        : const Color(0xFFE4A312);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B2D08),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFFF3B41A), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: imageUrl.trim().isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 102,
                        height: 82,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              Images.gym1Image,
                              width: 102,
                              height: 82,
                              fit: BoxFit.cover,
                            ),
                      )
                    : Image.asset(
                        Images.gym1Image,
                        width: 102,
                        height: 82,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: #$orderId',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFE3E6EC),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusBadge(label: status, color: statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            purchaseDate,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFD0D5DD),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFF3B41A),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFFBFC6D2),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFFE6EAF0),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
