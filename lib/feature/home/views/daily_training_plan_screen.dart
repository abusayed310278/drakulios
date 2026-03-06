import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../../profile/views/member_profile_screen.dart';

class DailyTrainingPlanScreen extends StatefulWidget {
  const DailyTrainingPlanScreen({super.key});

  @override
  State<DailyTrainingPlanScreen> createState() =>
      _DailyTrainingPlanScreenState();
}

class _DailyTrainingPlanScreenState extends State<DailyTrainingPlanScreen> {
  final TrainingShopApiService _api = TrainingShopApiService();
  final UserApiService _userApi = UserApiService();

  bool _loading = true;
  List<Map<String, dynamic>> _trainings = <Map<String, dynamic>>[];
  DateTime? _serverDate;
  String _displayName = 'Member';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadTraining();
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
      final meta = payload['meta'];
      DateTime? serverDate;
      if (meta is Map && meta['serverDate'] != null) {
        serverDate = DateTime.tryParse(meta['serverDate'].toString());
      }
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
      setState(() {
        _trainings = resolved;
        _serverDate = serverDate;
      });
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
    final headerDate = _formatHeaderDate(
      _serverDate ??
          _tryParseItemDate(_trainings.isNotEmpty ? _trainings.first : null),
    );

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
                  _DateBanner(title: 'Today\'s Challenge!', value: headerDate),
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

  String _formatHeaderDate(DateTime? date) {
    final d = date ?? DateTime.now();
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
    final day = d.day;
    final mod100 = day % 100;
    String suffix = 'th';
    if (mod100 < 11 || mod100 > 13) {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
      }
    }
    return '$day$suffix ${months[d.month - 1]} ${d.year}';
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
  const _DateBanner({required this.title, required this.value});

  final String title;
  final String value;

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
          Image.asset(
            Images.solarCalendarImage,
            width: 32,
            height: 32,
            color: const Color(0xFFF2B31A),
          ),
        ],
      ),
    );
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
