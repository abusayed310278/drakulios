import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/notification_api_service.dart';
import '../../shop/views/widgets/shop_badge_state.dart';
import 'notification_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationApiService _api = NotificationApiService();
  bool _loading = true;
  List<_NotificationItem> _items = <_NotificationItem>[];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final raw = await _api.getMyNotifications();
      final items = raw.map(_NotificationItem.fromMap).toList();
      final unreadCount = items.where((e) => !e.isRead).length;
      ShopBadgeState.setNotificationCount(unreadCount);
      if (!mounted) return;
      setState(() => _items = items);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Failed to load notifications';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load notifications');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }

  bool _isWithinLast7Days(DateTime time) {
    final now = DateTime.now();
    return now.difference(time).inDays <= 7;
  }

  Future<void> _openDetails(_NotificationItem item) async {
    if (item.id != null && !item.isRead) {
      try {
        await _api.markAsRead(item.id!);
      } catch (_) {}
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailsScreen(
          senderName: item.title,
          heading: item.heading ?? 'ATTENTION MEMBERS:',
          bullet: item.bullet ?? 'Update',
          body: item.body ?? '',
        ),
      ),
    );
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final todayItems = _items.where((e) => _isToday(e.createdAt)).toList();
    final weekItems = _items
        .where((e) => !_isToday(e.createdAt) && _isWithinLast7Days(e.createdAt))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFFC9CDD3),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Notifications',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFB1B1B1),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF3B41A),
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              if (todayItems.isNotEmpty) ...[
                                _SectionHeading(title: 'Today'),
                                const SizedBox(height: 4),
                                ...todayItems.map(
                                  (item) => _NotificationTile(
                                    item: item,
                                    onOpen: () => _openDetails(item),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              if (weekItems.isNotEmpty) ...[
                                _SectionHeading(title: 'This week'),
                                const SizedBox(height: 4),
                                ...weekItems.map(
                                  (item) => _NotificationTile(
                                    item: item,
                                    onOpen: () => _openDetails(item),
                                  ),
                                ),
                              ],
                              if (todayItems.isEmpty && weekItems.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 24),
                                  child: Center(
                                    child: Text(
                                      'No notifications found',
                                      style: TextStyle(
                                        color: Color(0xFF9AA1AE),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: const Color(0xFFE6E7EA),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onOpen});

  final _NotificationItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF2B31A),
            child: ClipOval(
              child: Image.asset(
                Images.profileImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 241),
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.title} ',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE6E7EA),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                          ),
                        ),
                        TextSpan(
                          text: item.message,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFBFC4CC),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.details ?? 'View Details',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFF2B31A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ).inkWell(onOpen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.details,
    this.heading,
    this.bullet,
    this.body,
  });

  factory _NotificationItem.fromMap(Map<String, dynamic> map) {
    final created =
        DateTime.tryParse((map['createdAt'] ?? '').toString()) ??
        DateTime.now();
    return _NotificationItem(
      id: map['_id']?.toString(),
      title: (map['title'] ?? 'Admin').toString(),
      message: (map['message'] ?? '').toString(),
      details: map['details']?.toString(),
      heading: map['heading']?.toString(),
      bullet: map['bullet']?.toString(),
      body: map['body']?.toString(),
      isRead: map['isRead'] == true,
      createdAt: created,
    );
  }

  final String? id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? details;
  final String? heading;
  final String? bullet;
  final String? body;
}

extension on Widget {
  Widget inkWell(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: this,
      ),
    );
  }
}
