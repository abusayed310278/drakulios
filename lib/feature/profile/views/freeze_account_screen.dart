import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';

class FreezeAccountScreen extends StatefulWidget {
  const FreezeAccountScreen({
    super.key,
    required this.memberName,
    required this.memberId,
    required this.phone,
    required this.email,
    required this.memberSince,
    required this.avatarUrl,
  });

  final String memberName;
  final String memberId;
  final String phone;
  final String email;
  final String memberSince;
  final String avatarUrl;

  @override
  State<FreezeAccountScreen> createState() => _FreezeAccountScreenState();
}

class _FreezeAccountScreenState extends State<FreezeAccountScreen> {
  final TrainingShopApiService _api = TrainingShopApiService();
  DateTime? _selectedStartDate;
  int? _selectedWeeks;
  bool _isSubmitting = false;
  bool _isLoadingStatus = false;
  static const List<int> _weekOptions = <int>[1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    _loadFreezeStatus();
  }

  Future<void> _loadFreezeStatus() async {
    setState(() => _isLoadingStatus = true);
    try {
      final res = await _api.getFreezeMembershipStatus();
      final dataRaw = res['data'];
      if (dataRaw is! Map || !mounted) return;
      final data = Map<String, dynamic>.from(dataRaw);
      final isFrozen = data['isFrozen'] == true;
      if (!isFrozen) return;

      final startDate = _parseDateFromAnyKey(data, <String>[
        'startDate',
        'freezeStartDate',
        'fromDate',
      ]);
      final endDate = _parseDateFromAnyKey(data, <String>[
        'endDate',
        'freezeEndDate',
        'toDate',
      ]);

      DateTime? resolvedStart = startDate;
      int? resolvedWeeks;
      if (endDate != null) {
        resolvedStart ??= _normalizeDate(DateTime.now());
        final diffDays = endDate.difference(resolvedStart).inDays;
        final calculatedWeeks = diffDays <= 0 ? 1 : (diffDays / 7).ceil();
        resolvedWeeks = calculatedWeeks.clamp(1, 4);
      }

      setState(() {
        _selectedStartDate = resolvedStart;
        _selectedWeeks = resolvedWeeks;
      });
    } catch (_) {
      // Keep screen usable even if status fetch fails.
    } finally {
      if (mounted) {
        setState(() => _isLoadingStatus = false);
      }
    }
  }

  DateTime? _parseDateFromAnyKey(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final raw = data[key]?.toString();
      if (raw == null || raw.trim().isEmpty) continue;
      final parsed = DateTime.tryParse(raw)?.toLocal();
      if (parsed != null) return _normalizeDate(parsed);
    }
    return null;
  }

  Future<void> _pickStartDate() async {
    final now = _normalizeDate(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _selectedStartDate = _normalizeDate(picked);
    });
  }

  String _startDateLabel() {
    final d = _selectedStartDate;
    if (d == null) return 'Enter start date..';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  DateTime? _calculatedEndDate() {
    final start = _selectedStartDate;
    final weeks = _selectedWeeks;
    if (start == null || weeks == null) return null;
    return _normalizeDate(start.add(Duration(days: weeks * 7)));
  }

  String _freezeSummaryLabel() {
    final start = _selectedStartDate;
    final weeks = _selectedWeeks;
    final end = _calculatedEndDate();
    if (start == null || weeks == null || end == null) {
      return 'Select start date and duration (1-4 weeks).';
    }
    final startText =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    final endText =
        '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
    return 'Freeze duration: $weeks week${weeks > 1 ? 's' : ''} ($startText to $endText)';
  }

  Future<void> _confirmFreeze() async {
    if (_isSubmitting) return;

    final startDate = _selectedStartDate;
    if (startDate == null) {
      CustomSnackbar.show('Please select freeze start date');
      return;
    }
    final selectedWeeks = _selectedWeeks;
    if (selectedWeeks == null) {
      CustomSnackbar.show('Please select freeze duration (1-4 weeks)');
      return;
    }
    final endDate = _normalizeDate(
      startDate.add(Duration(days: selectedWeeks * 7)),
    );

    setState(() => _isSubmitting = true);
    try {
      final res = await _api.freezeMembership(
        indefinite: false,
        endDate: endDate,
      );
      if (!mounted) return;
      CustomSnackbar.show(
        (res['message'] ?? 'Membership freeze updated successfully').toString(),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      CustomSnackbar.show(_extractErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message =
            data['message']?.toString() ??
            data['error']?.toString() ??
            data['details']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          return message;
        }
      }
    }
    return 'Failed to freeze membership. Please try again.';
  }

  DateTime _normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        'Freeze Account',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 34 / 2,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FreezeAvatar(imageUrl: widget.avatarUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.memberName,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 34 / 2,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _InfoText('Member ID : ${widget.memberId}'),
                            _InfoText('Contact no. : ${widget.phone}'),
                            _InfoText('Email : ${widget.email}'),
                            _InfoText('Member Since : ${widget.memberSince}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Freeze Duration',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18 / 1.3,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _OptionButton(
                    text: _startDateLabel(),
                    selected: _selectedStartDate != null,
                    onTap: (_isSubmitting || _isLoadingStatus)
                        ? () {}
                        : _pickStartDate,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weekOptions.map((week) {
                      return _WeekOptionButton(
                        week: week,
                        selected: _selectedWeeks == week,
                        onTap: (_isSubmitting || _isLoadingStatus)
                            ? () {}
                            : () => setState(() => _selectedWeeks = week),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _freezeSummaryLabel(),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF8FA0BF),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: _BottomButton(
                          title: 'Cancel',
                          bg: const Color(0xFF2A2513),
                          border: const Color(0xFFF2B31A),
                          onTap: (_isSubmitting || _isLoadingStatus)
                              ? () {}
                              : () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BottomButton(
                          title: _isSubmitting
                              ? 'Freezing...'
                              : 'Confirm Freeze',
                          bg: const Color(0xFFF2B31A),
                          border: const Color(0xFFF2B31A),
                          textColor: Colors.white,
                          onTap: (_isSubmitting || _isLoadingStatus)
                              ? () {}
                              : _confirmFreeze,
                        ),
                      ),
                    ],
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

class _InfoText extends StatelessWidget {
  const _InfoText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 38,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C224E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2C6CFF), width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: selected ? Colors.white : const Color(0xFF707070),
              fontSize: 16 / 1.3,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.title,
    required this.bg,
    required this.border,
    required this.onTap,
    this.textColor = Colors.white,
  });

  final String title;
  final Color bg;
  final Color border;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.1),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 16 / 1.3,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekOptionButton extends StatelessWidget {
  const _WeekOptionButton({
    required this.week,
    required this.selected,
    required this.onTap,
  });

  final int week;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '$week Week${week > 1 ? 's' : ''}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 36,
        width: 86,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C224E) : const Color(0xFF1E2024),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF2C6CFF) : const Color(0xFF3A3F47),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: selected ? Colors.white : const Color(0xFFE3E6EC),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _FreezeAvatar extends StatelessWidget {
  const _FreezeAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFF2A2F39),
      child: ClipOval(
        child: trimmed.isNotEmpty
            ? Image.network(
                trimmed,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _FreezeAvatarPlaceholder(),
              )
            : const _FreezeAvatarPlaceholder(),
      ),
    );
  }
}

class _FreezeAvatarPlaceholder extends StatelessWidget {
  const _FreezeAvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFF2A2F39),
      child: const Icon(Icons.person, color: Color(0xFFB1B1B1), size: 28),
    );
  }
}
