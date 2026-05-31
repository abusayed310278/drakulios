import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/network/api_service/notification_api_service.dart';
import '../../../../core/network/api_service/token_meneger.dart';
import '../../../../core/network/api_service/user_api_service.dart';
import '../../../../core/network/socket/notification_socket_service.dart';
import '../../notifications/view/notification_screen.dart';
import '../../profile/view/member_profile_screen.dart';
import '../../shop/widgets/shop_badge_state.dart';

class TrainingHeader extends StatefulWidget {
  const TrainingHeader({
    super.key,
    required this.activeIndex,
    required this.onTabChange,
    required this.dateTitle,
    required this.dateValue,
  });

  final int activeIndex;
  final ValueChanged<int> onTabChange;
  final String dateTitle;
  final String dateValue;

  @override
  State<TrainingHeader> createState() => _TrainingHeaderState();
}

class _TrainingHeaderState extends State<TrainingHeader> {
  final UserApiService _userApi = UserApiService();
  final NotificationApiService _notificationApi = NotificationApiService();
  final NotificationSocketService _socket = NotificationSocketService.instance;
  String _displayName = 'Member';
  String _avatarUrl = '';
  StreamSubscription<NotificationSocketEvent>? _socketSub;

  String _toCamelCase(String value) {
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
  void initState() {
    super.initState();
    _loadHeaderProfile();
    _loadNotificationCount();
    _initSocket();
  }

  Future<void> _loadHeaderProfile() async {
    try {
      final res = await _userApi.getProfile();
      final rawData = res['data'];
      final data = rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        final name = (data['name'] ?? '').toString().trim();
        final avatarRaw = data['avatar'];
        final avatar = avatarRaw is Map ? Map<String, dynamic>.from(avatarRaw) : const <String, dynamic>{};
        _displayName = _toCamelCase(name);
        _avatarUrl = (avatar['url'] ?? '').toString();
      });
      return;
    } catch (_) {}

    final savedName = (await TokenManager.getUserName())?.trim() ?? '';
    if (!mounted) return;
    setState(() => _displayName = _toCamelCase(savedName));
  }

  Future<void> _loadNotificationCount() async {
    try {
      final items = await _notificationApi.getMyNotifications();
      final count = items.where((e) => e['isRead'] != true).length;
      ShopBadgeState.setNotificationCount(count);
    } catch (_) {}
  }

  Future<void> _initSocket() async {
    await _socket.connect();
    if (!mounted) return;
    _socketSub = _socket.events.listen((event) {
      if (!mounted) return;
      switch (event.type) {
        case NotificationSocketEventType.created:
          ShopBadgeState.incrementNotification();
          _loadNotificationCount();
          break;
        case NotificationSocketEventType.updated:
          _loadNotificationCount();
          break;
        case NotificationSocketEventType.deleted:
          ShopBadgeState.decrementNotification();
          _loadNotificationCount();
          break;
        case NotificationSocketEventType.connected:
        case NotificationSocketEventType.disconnected:
          break;
      }
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Transform.translate(
              offset: const Offset(-15, 0),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFFC9CDD3),
                ),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  'Good Morning 🔥',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                TranslatedText(
                  _displayName,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  autoSize: true,
                ),
              ],
            ),
            const Spacer(),
            ValueListenableBuilder<int>(
              valueListenable: ShopBadgeState.notificationCount,
              builder: (context, notificationCount, _) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        )
                        .then((_) => _loadNotificationCount());
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: Image.asset(
                              Images.bellImage,
                              width: 20,
                              height: 20,
                              color: notificationCount > 0
                                  ? const Color(0xFFF3B41A)
                                  : const Color(0xFFC9CDD3),
                            ),
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              top: -3,
                              right: -4,
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: TranslatedText(
                                    notificationCount > 99
                                        ? '99+'
                                        : '$notificationCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MemberProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: _HeaderAvatar(avatarUrl: _avatarUrl),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _TabSwitcher(
          activeIndex: widget.activeIndex,
          onChange: widget.onTabChange,
        ),
        const SizedBox(height: 12),
        _DateCard(title: widget.dateTitle, date: widget.dateValue),
      ],
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = avatarUrl.trim();
    if (trimmedUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundColor: const Color(0xFF2A2F39),
        child: ClipOval(
          child: Image.network(
            trimmedUrl,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const _AvatarPlaceholder(),
          ),
        ),
      );
    }
    return const _AvatarPlaceholder();
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 12,
      backgroundColor: Color(0xFF2A2F39),
      child: Icon(Icons.person, size: 14, color: Color(0xFFC9CDD3)),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.activeIndex, required this.onChange});

  final int activeIndex;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Training',
            asset: Images.traningImage,
            selected: activeIndex == 0,
            onTap: () => onChange(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TabButton(
            label: 'Nutrition',
            icon: Icons.restaurant,
            selected: activeIndex == 1,
            onTap: () => onChange(1),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    this.icon,
    this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final String? asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2C6CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF2C6CFF) : const Color(0xFF2A2F39),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (asset != null)
              Image.asset(asset!, width: 16, height: 16, color: Colors.white)
            else
              Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            TranslatedText(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.title, required this.date});

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C224E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                title,
                style: const TextStyle(
                  color: Color(0xFFB7C0D0),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 94,
                height: 19,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: TranslatedText(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: InkWell(
              onTap: () {
                showDialog<void>(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.55),
                  builder: (_) => const _SessionCalendarDialog(),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Image.asset(
                  Images.solarCalendarImage,
                  width: 32,
                  height: 32,
                  color: const Color(0xFFF2B31A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCalendarDialog extends StatefulWidget {
  const _SessionCalendarDialog();

  @override
  State<_SessionCalendarDialog> createState() => _SessionCalendarDialogState();
}

class _SessionCalendarDialogState extends State<_SessionCalendarDialog> {
  static const _monthNames = <String>[
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

  int _selectedSession = 8;
  DateTime _displayedMonth = DateTime(2026, 2);
  DateTime _selectedDate = DateTime(2026, 2, 8);
  final Set<DateTime> _sessionDates = <DateTime>{
    DateTime(2026, 2, 3),
    DateTime(2026, 2, 4),
    DateTime(2026, 2, 5),
    DateTime(2026, 2, 6),
    DateTime(2026, 2, 7),
    DateTime(2026, 2, 8),
    DateTime(2026, 2, 9),
    DateTime(2026, 2, 10),
  };

  DateTime _key(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<int?> _pickYear() async {
    final years = List<int>.generate(101, (i) => 2000 + i);
    final initialIndex = years
        .indexOf(_displayedMonth.year)
        .clamp(0, years.length - 1);
    final controller = FixedExtentScrollController(initialItem: initialIndex);
    int tempYear = _displayedMonth.year;

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 280,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDBDBD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TranslatedText(
                    'Select Year',
                    style: TextStyle(
                      color: Color(0xFF202124),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: controller,
                      itemExtent: 40,
                      perspective: 0.002,
                      diameterRatio: 1.3,
                      onSelectedItemChanged: (index) {
                        setModalState(() => tempYear = years[index]);
                      },
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: years.length,
                        builder: (context, index) {
                          final year = years[index];
                          final selected = year == tempYear;
                          return Center(
                            child: TranslatedText(
                              '$year',
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF000000)
                                    : const Color(0xFF7D7D7D),
                                fontSize: selected ? 18 : 15,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(tempYear),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0B617),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const TranslatedText(''),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<int?> _pickMonth() async {
    final months = List<int>.generate(12, (i) => i + 1);
    final initialIndex = (_displayedMonth.month - 1).clamp(0, 11);
    final controller = FixedExtentScrollController(initialItem: initialIndex);
    int tempMonth = _displayedMonth.month;

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 280,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDBDBD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TranslatedText(
                    'Select Month',
                    style: TextStyle(
                      color: Color(0xFF202124),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: controller,
                      itemExtent: 40,
                      perspective: 0.002,
                      diameterRatio: 1.3,
                      onSelectedItemChanged: (index) {
                        setModalState(() => tempMonth = months[index]);
                      },
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: months.length,
                        builder: (context, index) {
                          final month = months[index];
                          final selected = month == tempMonth;
                          return Center(
                            child: TranslatedText(
                              _monthNames[month - 1],
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF000000)
                                    : const Color(0xFF7D7D7D),
                                fontSize: selected ? 18 : 15,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(tempMonth),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0B617),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const TranslatedText(''),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
      _selectedDate = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    });
  }

  void _setMonthYear(int month, int year) {
    setState(() {
      _displayedMonth = DateTime(year, month, 1);
      _selectedDate = DateTime(year, month, 1);
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _displayedMonth = DateTime(date.year, date.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              'Choose Session',
              style: TextStyle(
                color: Color(0xFF1F2126),
                fontSize: 30 / 2,
                fontWeight: FontWeight.w600,
              ),
              autoSize: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _SessionChip(
                  value: 4,
                  selected: _selectedSession == 4,
                  onTap: () => setState(() => _selectedSession = 4),
                ),
                const SizedBox(width: 8),
                _SessionChip(
                  value: 8,
                  selected: _selectedSession == 8,
                  onTap: () => setState(() => _selectedSession = 8),
                ),
                const SizedBox(width: 8),
                _SessionChip(
                  value: 12,
                  selected: _selectedSession == 12,
                  onTap: () => setState(() => _selectedSession = 12),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF1F2126),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 5,
                  child: InkWell(
                    onTap: () async {
                      final month = await _pickMonth();
                      if (month != null) {
                        _setMonthYear(month, _displayedMonth.year);
                      }
                    },
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFD4D4D4)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              _monthNames[_displayedMonth.month - 1],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF34353A),
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w400,
                              ),
                              autoSize: true,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: Color(0xFF34353A),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () async {
                      final year = await _pickYear();
                      if (year != null) {
                        _setMonthYear(_displayedMonth.month, year);
                      }
                    },
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      height: 34,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFD4D4D4)),
                      ),
                      child: TranslatedText(
                        '${_displayedMonth.year}',
                        style: const TextStyle(
                          color: Color(0xFF34353A),
                          fontSize: 30 / 2,
                          fontWeight: FontWeight.w400,
                        ),
                        autoSize: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF1F2126),
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeekText('Su'),
                _WeekText('Mo'),
                _WeekText('Tu'),
                _WeekText('We'),
                _WeekText('Th'),
                _WeekText('Fr'),
                _WeekText('Sa'),
              ],
            ),
            const SizedBox(height: 8),
            _CalendarGrid(
              displayedMonth: _displayedMonth,
              selectedDate: _selectedDate,
              sessionDates: _sessionDates,
              onDateSelected: _onDateSelected,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _sessionDates.add(_key(_selectedDate));
                  });
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0B617),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TranslatedText(
                      'Set Session',
                      style: TextStyle(
                        fontSize: 30 / 2,
                        fontWeight: FontWeight.w500,
                      ),
                      autoSize: true,
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionChip extends StatelessWidget {
  const _SessionChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5E6B9) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFFF0B617) : Colors.transparent,
          ),
        ),
        child: TranslatedText(
          '$value',
          style: const TextStyle(
            color: Color(0xFF2C2D30),
            fontSize: 30 / 2,
            fontWeight: FontWeight.w400,
          ),
          autoSize: true,
        ),
      ),
    );
  }
}

class _WeekText extends StatelessWidget {
  const _WeekText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      child: TranslatedText(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8E8E8E),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _CalendarDateCell {
  const _CalendarDateCell(this.date);

  final DateTime date;
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.displayedMonth,
    required this.selectedDate,
    required this.sessionDates,
    required this.onDateSelected,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<DateTime> sessionDates;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final days = _buildMonthCells(displayedMonth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth =
            day.date.year == displayedMonth.year &&
            day.date.month == displayedMonth.month;
        final isSelected =
            day.date.year == selectedDate.year &&
            day.date.month == selectedDate.month &&
            day.date.day == selectedDate.day;
        final isSession = sessionDates.contains(
          DateTime(day.date.year, day.date.month, day.date.day),
        );

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onDateSelected(day.date),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSession ? const Color(0xFFB9D5B4) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: const Color(0xFFF0B617), width: 1.4)
                  : null,
            ),
            child: TranslatedText(
              '${day.date.day}',
              style: TextStyle(
                color: isCurrentMonth
                    ? const Color(0xFF2D2D31)
                    : const Color(0xFFB7B7B7),
                fontSize: 30 / 2,
                fontWeight: FontWeight.w400,
              ),
              autoSize: true,
            ),
          ),
        );
      },
    );
  }

  List<_CalendarDateCell> _buildMonthCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final prevMonthDays = DateTime(month.year, month.month, 0).day;
    final startOffset = firstDay.weekday % 7;
    final totalSlots = (startOffset + daysInMonth) <= 35 ? 35 : 42;

    final result = <_CalendarDateCell>[];
    for (int i = 0; i < totalSlots; i++) {
      final dayNumber = i - startOffset + 1;
      if (dayNumber < 1) {
        result.add(
          _CalendarDateCell(
            DateTime(month.year, month.month - 1, prevMonthDays + dayNumber),
          ),
        );
      } else if (dayNumber > daysInMonth) {
        result.add(
          _CalendarDateCell(
            DateTime(month.year, month.month + 1, dayNumber - daysInMonth),
          ),
        );
      } else {
        result.add(
          _CalendarDateCell(DateTime(month.year, month.month, dayNumber)),
        );
      }
    }
    return result;
  }
}
