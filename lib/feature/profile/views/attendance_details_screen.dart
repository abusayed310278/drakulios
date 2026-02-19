import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';

class AttendanceDetailsScreen extends StatelessWidget {
  const AttendanceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-12, 0),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ),
                      Text(
                        'Attendance Details',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 30 / 2,
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
                        radius: 40,
                        backgroundColor: const Color(0xFF2A2F39),
                        child: ClipOval(child: Image.asset(Images.profileImage, width: 80, height: 80, fit: BoxFit.cover)),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stella Jacobs',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 34 / 2, fontWeight: FontWeight.w700, height: 1.2),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Member ID : 1212',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFD8DCE2),
                              fontSize: 25 / 2,
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
                    'Attendance Status',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 30 / 2, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  _StatusTile(text: 'Total Visits: 48 visits', imagePath: Images.totalvisitImage),
                  const SizedBox(height: 8),
                  _StatusTile(text: 'Average Stay: 1h 12m', imagePath: Images.averageImage),
                  const SizedBox(height: 8),
                  _StatusTile(text: 'Last Visit: 2 hours ago', imagePath: Images.hourglassImage),
                  const SizedBox(height: 18),
                  Text(
                    'Attendance Calendar',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 30 / 2, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  _CalendarCard(
                    onTapSeeDetails: (selectedDate) => _showAttendanceDialog(context, selectedDate),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context, DateTime selectedDate) {
    const monthNames = <String>[
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
    final formattedDate = '${monthNames[selectedDate.month - 1]} ${selectedDate.day.toString().padLeft(2, '0')}, ${selectedDate.year}';

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Attendance Details',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E1E1E),
                          fontSize: 34 / 2,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Color(0xFF7A7A7A), size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BulletLine(text: 'Date: $formattedDate'),
                _BulletLine(text: 'Entry Time: 03:00PM'),
                _BulletLine(text: 'Exit Time: 05:00PM'),
                _BulletLine(text: 'Duration: 2 hours'),
              ],
            ),
          ),
        );
      },
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
          Image.asset(imagePath, width: 20, height: 20, color: const Color(0xFFF3B41A)),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.outfit(color: const Color(0xFFF2F4F8), fontSize: 13, fontWeight: FontWeight.w400, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatefulWidget {
  const _CalendarCard({required this.onTapSeeDetails});

  final ValueChanged<DateTime> onTapSeeDetails;

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
  final Set<int> _activeDays = <int>{1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 14, 15};
  final Set<int> _alertDays = <int>{9, 10};

  DateTime _displayedMonth = DateTime(2026, 1);
  DateTime _selectedDate = DateTime(2026, 1, 1);

  Future<int?> _pickYear() async {
    final years = List<int>.generate(101, (i) => 2000 + i); // 2000..2100
    final initialIndex = years.indexOf(_displayedMonth.year).clamp(0, years.length - 1);
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
                  Text(
                    'Select Year',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF202124),
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
                            child: Text(
                              '$year',
                              style: GoogleFonts.outfit(
                                color: selected ? const Color(0xFF000000) : const Color(0xFF7D7D7D),
                                fontSize: selected ? 18 : 15,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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
                          backgroundColor: const Color(0xFFF3B41A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Done'),
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
    final initialIndex = (_displayedMonth.month - 1).clamp(0, months.length - 1);
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
                  Text(
                    'Select Month',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF202124),
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
                            child: Text(
                              _monthNames[month - 1],
                              style: GoogleFonts.outfit(
                                color: selected ? const Color(0xFF000000) : const Color(0xFF7D7D7D),
                                fontSize: selected ? 18 : 15,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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
                          backgroundColor: const Color(0xFFF3B41A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Done'),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, color: Color(0xFF202124), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              const SizedBox(width: 6),
              _SelectChip(
                text: _monthNames[_displayedMonth.month - 1],
                onSelected: () async {
                  final selectedMonth = await _pickMonth();
                  if (selectedMonth != null) {
                    _setMonthYear(selectedMonth, _displayedMonth.year);
                  }
                },
              ),
              const SizedBox(width: 8),
              _SelectChip(
                text: '${_displayedMonth.year}',
                onSelected: () async {
                  final selectedYear = await _pickYear();
                  if (selectedYear != null) {
                    _setMonthYear(_displayedMonth.month, selectedYear);
                  }
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, color: Color(0xFF202124), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _DayLabel('Su'),
              _DayLabel('Mo'),
              _DayLabel('Tu'),
              _DayLabel('We'),
              _DayLabel('Th'),
              _DayLabel('Fr'),
              _DayLabel('Sa'),
            ],
          ),
          const SizedBox(height: 8),
          _CalendarGrid(
            displayedMonth: _displayedMonth,
            selectedDate: _selectedDate,
            activeDays: _activeDays,
            alertDays: _alertDays,
            onDateSelected: _onDateSelected,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onTapSeeDetails(_selectedDate),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF3B41A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'See Details',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 28 / 2, fontWeight: FontWeight.w500, height: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
      _clampSelectionToMonth();
    });
  }

  void _setMonthYear(int month, int year) {
    setState(() {
      _displayedMonth = DateTime(year, month);
      _clampSelectionToMonth();
    });
  }

  void _clampSelectionToMonth() {
    if (_selectedDate.year == _displayedMonth.year && _selectedDate.month == _displayedMonth.month) {
      return;
    }
    _selectedDate = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _displayedMonth = DateTime(date.year, date.month);
    });
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({required this.text, required this.onSelected});

  final String text;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD7D7D7)),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: GoogleFonts.outfit(color: const Color(0xFF202124), fontSize: 30 / 2, fontWeight: FontWeight.w400, height: 1.2),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF202124)),
          ],
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(color: const Color(0xFF9A9A9A), fontSize: 12, fontWeight: FontWeight.w400, height: 1.2),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.displayedMonth,
    required this.selectedDate,
    required this.activeDays,
    required this.alertDays,
    required this.onDateSelected,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<int> activeDays;
  final Set<int> alertDays;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final days = _buildMonthCells(displayedMonth);

    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: days.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        final bool isSelected =
            day.date.year == selectedDate.year && day.date.month == selectedDate.month && day.date.day == selectedDate.day;
        final bool isCurrentMonth = day.date.month == displayedMonth.month && day.date.year == displayedMonth.year;
        final bool isActive = isCurrentMonth && activeDays.contains(day.date.day);
        final bool isAlert = isCurrentMonth && alertDays.contains(day.date.day);

        final fillColor = isAlert
            ? const Color(0xFFFFD7D7)
            : isActive
                ? const Color(0xFFC3E8B6)
                : Colors.transparent;
        final textColor = !isCurrentMonth
            ? const Color(0xFFB7B7B7)
            : isAlert
                ? const Color(0xFFD23434)
                : const Color(0xFF2A2A2A);

        return InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => onDateSelected(day.date),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: const Color(0xFF41B136), width: 3) : null,
            ),
            child: Center(
              child: Text(
                '${day.date.day}',
                style: GoogleFonts.outfit(color: textColor, fontSize: 14, fontWeight: FontWeight.w500, height: 1.2),
              ),
            ),
          ),
        );
      },
    );
  }

  List<_DayCell> _buildMonthCells(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final prevMonthDays = DateTime(month.year, month.month, 0).day;
    final startOffset = firstDay.weekday % 7;
    final totalSlots = (startOffset + daysInMonth) <= 35 ? 35 : 42;

    final result = <_DayCell>[];
    for (int i = 0; i < totalSlots; i++) {
      final dayNumber = i - startOffset + 1;
      if (dayNumber < 1) {
        result.add(_DayCell(DateTime(month.year, month.month - 1, prevMonthDays + dayNumber)));
      } else if (dayNumber > daysInMonth) {
        result.add(_DayCell(DateTime(month.year, month.month + 1, dayNumber - daysInMonth)));
      } else {
        result.add(_DayCell(DateTime(month.year, month.month, dayNumber)));
      }
    }
    return result;
  }
}

class _DayCell {
  const _DayCell(this.date);

  final DateTime date;
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: GoogleFonts.outfit(color: const Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w400, height: 1.2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(color: const Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w400, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
