import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import 'widgets/training_header.dart';

class TrainingNutritionScreen extends StatefulWidget {
  const TrainingNutritionScreen({super.key});

  @override
  State<TrainingNutritionScreen> createState() =>
      _TrainingNutritionScreenState();
}

class _TrainingNutritionScreenState extends State<TrainingNutritionScreen> {
  int _tabIndex = 0;
  final TrainingShopApiService _api = TrainingShopApiService();
  bool _loadingTraining = true;
  bool _loadingNutrition = true;
  List<Map<String, dynamic>> _trainings = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _nutritions = <Map<String, dynamic>>[];
  DateTime? _trainingServerDate;
  DateTime? _nutritionServerDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _onTabChange(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);

    if (index == 1) {
      setState(() => _loadingNutrition = true);
      _loadNutrition();
      return;
    }

    setState(() => _loadingTraining = true);
    _loadTraining();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadTraining(), _loadNutrition()]);
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
        _trainingServerDate = serverDate;
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
      if (mounted) setState(() => _loadingTraining = false);
    }
  }

  Future<void> _loadNutrition() async {
    try {
      final payload = await _api.getTodayNutritionsBundle();
      final data = _toMapList(payload['data']);
      final meta = payload['meta'];
      DateTime? serverDate;
      if (meta is Map && meta['serverDate'] != null) {
        serverDate = DateTime.tryParse(meta['serverDate'].toString());
      }

      var resolved = data;
      if (resolved.isEmpty) {
        final mine = await _api.getMyNutritions();
        final today = DateTime.now();
        final filtered = mine
            .where((e) => _isSameDay(_tryParseItemDate(e), today))
            .toList();
        resolved = filtered.isNotEmpty ? filtered : mine;
      }

      if (!mounted) return;
      setState(() {
        _nutritions = resolved;
        _nutritionServerDate = serverDate;
      });
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Failed to load nutritions';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load nutritions');
    } finally {
      if (mounted) setState(() => _loadingNutrition = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerDate = _tabIndex == 0
        ? _formatHeaderDate(
            _trainingServerDate ??
                _tryParseItemDate(
                  _trainings.isNotEmpty ? _trainings.first : null,
                ),
          )
        : _formatHeaderDate(
            _nutritionServerDate ??
                _tryParseItemDate(
                  _nutritions.isNotEmpty ? _nutritions.first : null,
                ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TrainingHeader(
                      activeIndex: _tabIndex,
                      onTabChange: _onTabChange,
                      dateTitle: _tabIndex == 0
                          ? 'Today\'s Challenge!'
                          : 'Today\'s Meal!',
                      dateValue: headerDate,
                    ),
                    const SizedBox(height: 12),
                    if (_tabIndex == 0) ...[
                      if (_loadingTraining)
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
                    ] else ...[
                      if (_loadingNutrition)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF3B41A),
                          ),
                        )
                      else if (_nutritions.isEmpty)
                        const _EmptyState(text: 'No nutrition found for today')
                      else
                        ...List.generate(_nutritions.length, (index) {
                          final item = _nutritions[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _nutritions.length - 1 ? 0 : 10,
                            ),
                            child: _MealCard(
                              title: (item['name'] ?? 'Meal').toString(),
                              time: (item['time'] ?? '').toString(),
                              subtitle:
                                  'P: ${(item['protein'] ?? 0)}g  C: ${(item['carbs'] ?? 0)}g  F: ${(item['fat'] ?? 0)}g  ${(item['cal'] ?? 0)}cal',
                              asset: Images.breakfastImage,
                            ),
                          );
                        }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _tryParseItemDate(Map<String, dynamic>? item) {
    if (item == null) return null;
    final raw =
        item['date'] ??
        item['nutritionDate'] ??
        item['forDate'] ??
        item['createdAt'] ??
        item['updatedAt'];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
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
            final chips = _buildChips(item);
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == rows.length - 1 ? 0 : 8,
              ),
              child: _WorkoutRow(
                title: (item['name'] ?? 'Workout').toString(),
                chips: chips,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.title,
    required this.time,
    required this.asset,
    required this.subtitle,
  });

  final String title;
  final String time;
  final String asset;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2513),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2B31A), width: 1.1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(asset, width: 54, height: 54, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }
}
