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

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) return 'No purchase yet';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'No purchase yet';
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
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _purchases.length - 1 ? 0 : 10,
                            ),
                            child: _PurchaseCard(
                              orderId: (item['orderId'] ?? 'N/A').toString(),
                              title: (item['title'] ?? 'Product').toString(),
                              price: _toPrice(item['price']),
                              imageUrl: (item['imageUrl'] ?? '').toString(),
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
  });

  final String orderId;
  final String title;
  final String price;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    errorBuilder: (context, error, stackTrace) => Image.asset(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
