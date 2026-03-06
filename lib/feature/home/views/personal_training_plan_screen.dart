import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../../profile/views/member_profile_screen.dart';

class PersonalTrainingPlanScreen extends StatefulWidget {
  const PersonalTrainingPlanScreen({super.key});

  @override
  State<PersonalTrainingPlanScreen> createState() =>
      _PersonalTrainingPlanScreenState();
}

class _PersonalTrainingPlanScreenState
    extends State<PersonalTrainingPlanScreen> {
  final TrainingShopApiService _api = TrainingShopApiService();
  final UserApiService _userApi = UserApiService();

  bool _loading = true;
  List<Map<String, dynamic>> _trainings = <Map<String, dynamic>>[];
  String _displayName = 'Member';
  String _avatarUrl = '';

  int _selectedSession = 8;
  DateTime _displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime _selectedDate = DateTime.now();
  final Set<DateTime> _sessionDates = <DateTime>{};

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadTraining();
    for (int i = 0; i < 8; i++) {
      _sessionDates.add(
        DateTime(DateTime.now().year, DateTime.now().month, i + 3),
      );
    }
  }

  Future<void> _loadProfile() async {
    try {
      final res = await _userApi.getProfile();
      final data = (res['data'] ?? {}) as Map;
      if (!mounted) return;
      setState(() {
        _displayName = _toCamelCase((data['name'] ?? '').toString().trim());
        _avatarUrl = (data['avatar']?['url'] ?? '').toString();
      });
      return;
    } catch (_) {}

    final savedName = (await TokenManager.getUserName())?.trim() ?? '';
    if (!mounted) return;
    setState(() => _displayName = _toCamelCase(savedName));
  }

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

  Future<void> _loadTraining() async {
    try {
      final payload = await _api.getTodayTrainingsBundle();
      final data = _toMapList(payload['data']);
      var resolved = data;
      if (resolved.isEmpty) {
        final mine = await _api.getMyTrainings();
        final today = DateTime.now();
        final filtered = mine
            .where((e) => _isSameDay(_tryParseItemDate(e), today))
            .toList();
        resolved = filtered.isNotEmpty ? filtered : mine;
      }

      if (!mounted) return;
      setState(() => _trainings = resolved);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Failed to load trainings';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load trainings');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rangeText = _formatSessionRange();

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PlanHeader(displayName: _displayName, avatarUrl: _avatarUrl),
                  const SizedBox(height: 12),
                  _DateBanner(
                    title: '$_selectedSession Training Sessions',
                    value: rangeText,
                    onCalendarTap: _openSessionCalendar,
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF3B41A),
                      ),
                    )
                  else if (_trainings.isEmpty)
                    const _EmptyState(text: 'No training found for today')
                  else
                    _TrainingCard(
                      rows: _trainings,
                      imageUrl: _extractImageUrl(
                        _trainings.isNotEmpty ? _trainings.first : null,
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

  Future<void> _openSessionCalendar() async {
    final res = await showDialog<_SessionDialogResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _SessionCalendarDialog(
        selectedSession: _selectedSession,
        displayedMonth: _displayedMonth,
        selectedDate: _selectedDate,
        sessionDates: _sessionDates,
      ),
    );
    if (res == null || !mounted) return;
    setState(() {
      _selectedSession = res.selectedSession;
      _displayedMonth = res.displayedMonth;
      _selectedDate = res.selectedDate;
      _sessionDates
        ..clear()
        ..addAll(res.sessionDates);
    });
  }

  String _formatSessionRange() {
    if (_sessionDates.isEmpty) return 'No sessions selected';
    final sorted = _sessionDates.toList()..sort((a, b) => a.compareTo(b));
    final first = sorted.first;
    final last = sorted.last;
    return '${_formatShort(first)} - ${_formatShort(last)}';
  }

  String _formatShort(DateTime d) {
    const months = <String>[
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
    return '${d.day}${_daySuffix(d.day)} ${months[d.month - 1]} ${d.year}';
  }

  String _daySuffix(int day) {
    final mod100 = day % 100;
    if (mod100 >= 11 && mod100 <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  List<Map<String, dynamic>> _toMapList(dynamic dataRaw) {
    if (dataRaw is List) {
      return dataRaw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  String? _extractImageUrl(Map<String, dynamic>? row) {
    if (row == null) return null;
    final imageRaw = row['image'];
    if (imageRaw is Map && imageRaw['url'] != null) {
      final url = imageRaw['url'].toString().trim();
      return url.isEmpty ? null : url;
    }
    if (imageRaw is String) {
      final url = imageRaw.trim();
      return url.isEmpty ? null : url;
    }
    return null;
  }

  DateTime? _tryParseItemDate(Map<String, dynamic>? item) {
    if (item == null) return null;
    final raw =
        item['date'] ??
        item['forDate'] ??
        item['createdAt'] ??
        item['updatedAt'];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({required this.displayName, required this.avatarUrl});

  final String displayName;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final trimmed = avatarUrl.trim();
    return Row(
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
            const Text(
              'Good Morning 🔥',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              displayName,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 24 / 2,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.notifications, color: Color(0xFFC9CDD3), size: 20),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MemberProfileScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF2A2F39),
            backgroundImage: trimmed.isNotEmpty ? NetworkImage(trimmed) : null,
            child: trimmed.isEmpty
                ? const Icon(Icons.person, size: 14, color: Color(0xFFC9CDD3))
                : null,
          ),
        ),
      ],
    );
  }
}

class _DateBanner extends StatelessWidget {
  const _DateBanner({
    required this.title,
    required this.value,
    required this.onCalendarTap,
  });

  final String title;
  final String value;
  final VoidCallback onCalendarTap;

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
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFB7C0D0),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onCalendarTap,
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              Images.solarCalendarImage,
              width: 32,
              height: 32,
              color: const Color(0xFFF2B31A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionDialogResult {
  const _SessionDialogResult({
    required this.selectedSession,
    required this.displayedMonth,
    required this.selectedDate,
    required this.sessionDates,
  });

  final int selectedSession;
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<DateTime> sessionDates;
}

class _SessionCalendarDialog extends StatefulWidget {
  const _SessionCalendarDialog({
    required this.selectedSession,
    required this.displayedMonth,
    required this.selectedDate,
    required this.sessionDates,
  });

  final int selectedSession;
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<DateTime> sessionDates;

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

  late int _selectedSession;
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  late Set<DateTime> _sessionDates;

  @override
  void initState() {
    super.initState();
    _selectedSession = widget.selectedSession;
    _displayedMonth = DateTime(
      widget.displayedMonth.year,
      widget.displayedMonth.month,
    );
    _selectedDate = widget.selectedDate;
    _sessionDates = widget.sessionDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  DateTime _key(DateTime date) => DateTime(date.year, date.month, date.day);

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
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
            const Text(
              'Choose Session',
              style: TextStyle(
                color: Color(0xFF1F2126),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
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
                Expanded(
                  child: Center(
                    child: Text(
                      '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                      style: const TextStyle(
                        color: Color(0xFF34353A),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
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
                  Navigator.of(context).pop(
                    _SessionDialogResult(
                      selectedSession: _selectedSession,
                      displayedMonth: _displayedMonth,
                      selectedDate: _selectedDate,
                      sessionDates: _sessionDates,
                    ),
                  );
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
                    Text(
                      'Set Session',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
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
        child: Text(
          '$value',
          style: const TextStyle(
            color: Color(0xFF2C2D30),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
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
      child: Text(
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
            child: Text(
              '${day.date.day}',
              style: TextStyle(
                color: isCurrentMonth
                    ? const Color(0xFF2D2D31)
                    : const Color(0xFFB7B7B7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
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

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({required this.rows, this.imageUrl});

  final List<Map<String, dynamic>> rows;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2024),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    height: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) => Image.asset(
                      Images.gym1Image,
                      height: 170,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(Images.gym1Image, height: 170, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          ...List.generate(rows.length, (index) {
            final item = rows[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == rows.length - 1 ? 0 : 8,
              ),
              child: _WorkoutRow(
                title: (item['name'] ?? 'Workout').toString(),
                chips: _buildChips(item),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<String> _buildChips(Map<String, dynamic> item) {
    final chips = <String>[];
    void addChip(dynamic raw, String suffix) {
      if (raw == null) return;
      final v = raw.toString().trim();
      if (v.isEmpty || v == '-') return;
      chips.add('$v $suffix');
    }

    addChip(item['sets'] ?? item['set'], 'Set');
    addChip(item['weight'], 'kg');
    addChip(item['reps'], 'Reps');
    addChip(item['rest'], 'Rest');

    if (chips.isEmpty) chips.add('No details');
    return chips.take(3).toList();
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.title, required this.chips});

  final String title;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2513),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF2B31A), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B5C16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2024),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFC9CDD3),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
