import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';

import '../../../core/language/translated_text.dart';
import '../../../core/common/widgets/page_loading_overlay.dart';
import '../../../core/constants/assets.dart';
import '../controller/purchase_history_controller.dart';
import '../model/purchase_history_data.dart';
import '../model/purchase_history_item.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final PurchaseHistoryController _controller = PurchaseHistoryController();

  bool _loading = true;
  PurchaseHistoryData? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final loaded = await _controller.loadData();
      if (!mounted) return;
      setState(() => _data = loaded);
    } catch (error) {
      CustomSnackbar.show(_controller.parseError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'delivered') return const Color(0xFF3ECF8E);
    if (normalized == 'sent') return const Color(0xFF59B7FF);
    if (normalized == 'processing') return const Color(0xFFF3B41A);
    if (normalized == 'canceled') return const Color(0xFFFF7B7B);
    return const Color(0xFFE4A312);
  }

  Future<void> _openPurchaseDetails(PurchaseHistoryItem item) async {
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
                    TranslatedText(
                      'Purchase Details',
                      style: TextStyle(
                        color: Color(0xFFF5F7FA),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _StatusBadge(
                      label: item.status,
                      color: _statusColor(item.status),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailRow(label: 'Order ID', value: item.orderId),
                _DetailRow(label: 'Product', value: item.title),
                _DetailRow(
                  label: 'Price',
                  value: _controller.toPrice(item.price),
                ),
                _DetailRow(label: 'Quantity', value: '${item.quantity}'),
                _DetailRow(label: 'Purchase Date', value: item.purchaseDate),
                _DetailRow(
                  label: 'Shipping Address',
                  value: item.shippingAddress,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final name = data?.name ?? 'Member';
    final memberId = data?.memberId ?? '';
    final avatarUrl = data?.avatarUrl ?? '';

    if (_loading && data == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF050608),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF3B41A)),
        ),
      );
    }

    final purchases = data?.purchases ?? const <PurchaseHistoryItem>[];

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
                          TranslatedText(
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
                              TranslatedText(
                                name,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              TranslatedText(
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
                      TranslatedText(
                        'Purchase Status',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StatusTile(
                        text:
                            'Pending Orders: ${data?.pendingOrders ?? 0}',
                      ),
                      const SizedBox(height: 8),
                      _StatusTile(
                        text:
                            'Last Purchase: ${data?.lastPurchaseText ?? 'No purchase yet'}',
                      ),
                      const SizedBox(height: 14),
                      TranslatedText(
                        'Purchase List',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (purchases.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Center(
                            child: TranslatedText(
                              'No purchase history yet',
                              style: TextStyle(
                                color: Color(0xFF9AA1AE),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate(purchases.length, (index) {
                          final item = purchases[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == purchases.length - 1 ? 0 : 10,
                            ),
                            child: _PurchaseCard(
                              orderId: item.orderId,
                              title: item.title,
                              price: _controller.toPrice(item.price),
                              imageUrl: item.imageUrl,
                              status: item.status,
                              purchaseDate: item.purchaseDate,
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
          TranslatedText(
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
                    TranslatedText(
                      'Order ID: #$orderId',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFE3E6EC),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TranslatedText(
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
                    TranslatedText(
                      price,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      autoSize: true,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusBadge(label: status, color: statusColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TranslatedText(
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
      child: TranslatedText(
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
            child: TranslatedText(
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
            child: TranslatedText(
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
