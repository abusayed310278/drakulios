import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/language/translated_text.dart';
import '../controller/notification_controller.dart';
import '../model/notification_item.dart';
import 'notification_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController _controller = NotificationController();
  bool _loading = true;
  List<NotificationItem> _items = <NotificationItem>[];
  Timer? _loadingWatchdog;
  bool _requestInFlight = false;

  @override
  void initState() {
    super.initState();
    _loadingWatchdog = Timer(const Duration(seconds: 18), () {
      if (!mounted || !_loading) return;
      setState(() => _loading = false);
    });
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    if (mounted) setState(() => _loading = true);
    try {
      final items = await _controller
          .loadNotifications()
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = <NotificationItem>[]);
    } finally {
      _requestInFlight = false;
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isToday(DateTime time) {
    return _controller.isToday(time);
  }

  bool _isWithinLast7Days(DateTime time) {
    return _controller.isWithinLast7Days(time);
  }

  Future<void> _openDetails(NotificationItem item) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailsScreen(
          senderName: item.title,
          senderAvatarUrl: item.senderAvatarUrl,
          heading: item.heading ?? 'ATTENTION MEMBERS:',
          bullet: item.bullet ?? 'Update',
          body: item.body ?? '',
        ),
      ),
    );
    _loadNotifications();
  }

  @override
  void dispose() {
    _loadingWatchdog?.cancel();
    super.dispose();
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
                        if (widget.showBackButton)
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
                          )
                        else
                          const SizedBox(width: 24, height: 24),
                        const SizedBox(width: 12),
                        TranslatedText(
                          'Notifications',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFB1B1B1),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                          autoSize: true,
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
                                Padding(
                                  padding: EdgeInsets.only(top: 24),
                                  child: Center(
                                    child: TranslatedText(
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
    return TranslatedText(
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

  final NotificationItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationAvatar(avatarUrl: item.senderAvatarUrl),
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
                TranslatedText(
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

class _NotificationAvatar extends StatelessWidget {
  const _NotificationAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = avatarUrl?.trim() ?? '';

    if (trimmedUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFF2B31A),
        child: ClipOval(
          child: Image.network(
            trimmedUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const _NotificationAvatarPlaceholder();
            },
          ),
        ),
      );
    }

    return const _NotificationAvatarPlaceholder();
  }
}

class _NotificationAvatarPlaceholder extends StatelessWidget {
  const _NotificationAvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Color(0xFFF2B31A),
      child: Icon(Icons.person, size: 20, color: Color(0xFF050608)),
    );
  }
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
