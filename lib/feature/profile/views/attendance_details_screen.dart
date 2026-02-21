import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/common/widgets/page_loading_overlay.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';

class AttendanceDetailsScreen extends StatefulWidget {
  const AttendanceDetailsScreen({super.key});

  @override
  State<AttendanceDetailsScreen> createState() =>
      _AttendanceDetailsScreenState();
}

class _AttendanceDetailsScreenState extends State<AttendanceDetailsScreen> {
  final UserApiService _userApi = UserApiService();
  final TrainingShopApiService _api = TrainingShopApiService();

  bool _loading = true;
  Map<String, dynamic> _profile = const {};
  int _displayMonth = DateTime.now().month;
  int _displayYear = DateTime.now().year;
  int _totalVisits = 0;
  int _avgStayMinutes = 0;
  String _lastVisitText = 'No visits yet';
  Set<int> _activeDays = <int>{};
  Set<int> _missedDays = <int>{};
  Map<String, Map<String, dynamic>> _dayDetails =
      <String, Map<String, dynamic>>{};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final profileRes = await _userApi.getProfile();
      final attendanceRes = await _api.getMyAttendance(
        year: _displayYear,
        month: _displayMonth,
      );
      final profile = Map<String, dynamic>.from(
        (profileRes['data'] ?? {}) as Map,
      );
      final data = Map<String, dynamic>.from(
        (attendanceRes['data'] ?? {}) as Map,
      );
      final active = ((data['attendedDays'] ?? []) as List)
          .whereType<num>()
          .map((e) => e.toInt())
          .toSet();
      final missed = ((data['missedDays'] ?? []) as List)
          .whereType<num>()
          .map((e) => e.toInt())
          .toSet();
      final details = <String, Map<String, dynamic>>{};
      final rows = (data['dayDetails'] ?? []) as List;
      for (final row in rows.whereType<Map>()) {
        final m = Map<String, dynamic>.from(row);
        final date = (m['date'] ?? '').toString();
        if (date.isNotEmpty) details[date] = m;
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _totalVisits = (data['totalVisits'] as num?)?.toInt() ?? 0;
        _avgStayMinutes = (data['averageStayMinutes'] as num?)?.toInt() ?? 0;
        _lastVisitText = _relativeTime((data['lastVisitAt'] ?? '').toString());
        _activeDays = active;
        _missedDays = missed;
        _dayDetails = details;
      });
    } on DioException catch (e) {
      final payload = e.response?.data;
      final msg = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : payload is Map && payload['error'] != null
          ? payload['error'].toString()
          : 'Failed to load attendance';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load attendance');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _relativeTime(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'No visits yet';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  String _formatDuration(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  String _fmtClock(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '--';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$mm$ampm';
  }

  void _showAttendanceDialog(DateTime selectedDate) {
    final key =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final detail = _dayDetails[key];
    final durationMinutes = (detail?['durationMinutes'] as num?)?.toInt() ?? 0;
    final entry = _fmtClock((detail?['entryTime'] ?? '').toString());
    final exit = _fmtClock((detail?['exitTime'] ?? '').toString());

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Attendance Details',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E1E1E),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF7A7A7A),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BulletLine(text: 'Date: $key'),
                _BulletLine(text: 'Entry Time: $entry'),
                _BulletLine(text: 'Exit Time: $exit'),
                _BulletLine(
                  text: 'Duration: ${_formatDuration(durationMinutes)}',
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
    final name = (_profile['name'] ?? 'Member').toString();
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
                            'Attendance Details',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFE5E7EB),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF2A2F39),
                            child: ClipOval(
                              child: avatarUrl.trim().isNotEmpty
                                  ? Image.network(
                                      avatarUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                Images.profileImage,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                  : Image.asset(
                                      Images.profileImage,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Member ID : $memberId',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFD8DCE2),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Attendance Status',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StatusTile(
                        text: 'Total Visits: $_totalVisits visits',
                        imagePath: Images.totalvisitImage,
                      ),
                      const SizedBox(height: 8),
                      _StatusTile(
                        text:
                            'Average Stay: ${_formatDuration(_avgStayMinutes)}',
                        imagePath: Images.averageImage,
                      ),
                      const SizedBox(height: 8),
                      _StatusTile(
                        text: 'Last Visit: $_lastVisitText',
                        imagePath: Images.hourglassImage,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Attendance Calendar',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _CalendarCard(
                        month: _displayMonth,
                        year: _displayYear,
                        activeDays: _activeDays,
                        alertDays: _missedDays,
                        onChangedMonthYear: (month, year) {
                          setState(() {
                            _displayMonth = month;
                            _displayYear = year;
                          });
                          _loadAll();
                        },
                        onTapSeeDetails: _showAttendanceDialog,
                      ),
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
  const _StatusTile({required this.text, required this.imagePath});

  final String text;
  final String imagePath;

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
          Image.asset(
            imagePath,
            width: 20,
            height: 20,
            color: const Color(0xFFF3B41A),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.outfit(
              color: const Color(0xFFF2F4F8),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF1E1E1E)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E1E1E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatefulWidget {
  const _CalendarCard({
    required this.month,
    required this.year,
    required this.activeDays,
    required this.alertDays,
    required this.onTapSeeDetails,
    required this.onChangedMonthYear,
  });

  final int month;
  final int year;
  final Set<int> activeDays;
  final Set<int> alertDays;
  final ValueChanged<DateTime> onTapSeeDetails;
  final void Function(int month, int year) onChangedMonthYear;

  @override
  State<_CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<_CalendarCard> {
  static const _monthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekdays = <String>['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  late int _month;
  late int _year;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
    _year = widget.year;
    _selected = DateTime(_year, _month, 1);
  }

  @override
  void didUpdateWidget(covariant _CalendarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month || oldWidget.year != widget.year) {
      _month = widget.month;
      _year = widget.year;
      _selected = DateTime(_year, _month, 1);
    }
  }

  void _moveMonth(int delta) {
    final next = DateTime(_year, _month + delta, 1);
    setState(() {
      _month = next.month;
      _year = next.year;
      _selected = DateTime(_year, _month, 1);
    });
    widget.onChangedMonthYear(_month, _year);
  }

  Future<void> _pickMonthBottomSheet() async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFFF8F8F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Select Month',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E1E1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _monthNames.length,
                    separatorBuilder: (_, index) =>
                        const Divider(height: 1, color: Color(0xFFE6E6E6)),
                    itemBuilder: (context, i) {
                      final value = i + 1;
                      final selected = value == _month;
                      return ListTile(
                        dense: true,
                        onTap: () => Navigator.of(context).pop(value),
                        title: Text(
                          _monthNames[i],
                          style: GoogleFonts.outfit(
                            color: selected
                                ? const Color(0xFFF3B41A)
                                : const Color(0xFF25272C),
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: selected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFFF3B41A),
                                size: 18,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked == null || picked == _month) return;
    setState(() => _month = picked);
    widget.onChangedMonthYear(_month, _year);
  }

  Future<void> _pickYearBottomSheet() async {
    final years = List<int>.generate(101, (i) => 2050 - i);
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFFF8F8F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Select Year',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E1E1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: years.length,
                    separatorBuilder: (_, index) =>
                        const Divider(height: 1, color: Color(0xFFE6E6E6)),
                    itemBuilder: (context, i) {
                      final value = years[i];
                      final selected = value == _year;
                      return ListTile(
                        dense: true,
                        onTap: () => Navigator.of(context).pop(value),
                        title: Text(
                          '$value',
                          style: GoogleFonts.outfit(
                            color: selected
                                ? const Color(0xFFF3B41A)
                                : const Color(0xFF25272C),
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: selected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFFF3B41A),
                                size: 18,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked == null || picked == _year) return;
    setState(() => _year = picked);
    widget.onChangedMonthYear(_month, _year);
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_year, _month, 1);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final leading = firstDay.weekday % 7;
    final cells = <Widget>[];

    for (final w in _weekdays) {
      cells.add(
        Center(
          child: Text(
            w,
            style: GoogleFonts.outfit(
              color: const Color(0xFF9EA3AA),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox(height: 38));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_year, _month, day);
      final selected =
          _selected?.year == _year &&
          _selected?.month == _month &&
          _selected?.day == day;
      final active = widget.activeDays.contains(day);
      final alert = widget.alertDays.contains(day);
      Color? fill;
      Color textColor = const Color(0xFF2A2F36);
      if (active) {
        fill = const Color(0xFFB8DFAB);
      } else if (alert) {
        fill = const Color(0xFFF7D4D8);
        textColor = const Color(0xFFCF4E4E);
      }
      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selected = date),
          child: Container(
            height: 38,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: const Color(0xFF39A935), width: 3)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _moveMonth(-1),
                icon: const Icon(Icons.chevron_left, color: Color(0xFF3C3F45)),
              ),
              InkWell(
                onTap: _pickMonthBottomSheet,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _monthNames[_month - 1],
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF2A2F36),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF8D9198),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _pickYearBottomSheet,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$_year',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF2A2F36),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF8D9198),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _moveMonth(1),
                icon: const Icon(Icons.chevron_right, color: Color(0xFF3C3F45)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => widget.onTapSeeDetails(_selected!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3B41A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('See Details'),
            ),
          ),
        ],
      ),
    );
  }
}
