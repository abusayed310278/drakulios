import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../controller/home_training_controller.dart';
import '../widgets/training_header.dart';

class TrainingNutritionScreen extends StatefulWidget {
  const TrainingNutritionScreen({super.key});

  @override
  State<TrainingNutritionScreen> createState() =>
      _TrainingNutritionScreenState();
}

class _TrainingNutritionScreenState extends State<TrainingNutritionScreen> {
  int _tabIndex = 0;
  final HomeTrainingController _controller = HomeTrainingController();
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
      final feed = await _controller.loadTodayTrainings();
      if (!mounted) return;
      setState(() {
        _trainings = feed.items;
        _trainingServerDate = feed.serverDate;
      });
    } catch (error) {
      final msg = _controller.readErrorMessage(
        error,
        fallback: 'Failed to load trainings',
      );
      CustomSnackbar.show(msg);
    } finally {
      if (mounted) setState(() => _loadingTraining = false);
    }
  }

  Future<void> _loadNutrition() async {
    try {
      final feed = await _controller.loadTodayNutritions();

      if (!mounted) return;
      setState(() {
        _nutritions = feed.items;
        _nutritionServerDate = feed.serverDate;
      });
    } catch (error) {
      final msg = _controller.readErrorMessage(
        error,
        fallback: 'Failed to load nutritions',
      );
      CustomSnackbar.show(msg);
    } finally {
      if (mounted) setState(() => _loadingNutrition = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerDate = _tabIndex == 0
        ? _formatHeaderDate(
            _trainingServerDate ??
                _controller.tryParseItemDate(
                  _trainings.isNotEmpty ? _trainings.first : null,
                ),
          )
        : _formatHeaderDate(
            _nutritionServerDate ??
                _controller.tryParseItemDate(
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
                          imageUrl: _controller.extractImageUrl(
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

  String _formatHeaderDate(DateTime? date) {
    return _controller.formatHeaderDate(date);
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
          TranslatedText(
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
                    child: TranslatedText(
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
                TranslatedText(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                TranslatedText(
                  time,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                const SizedBox(height: 4),
                TranslatedText(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                TranslatedText(
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
      child: TranslatedText(text, style: const TextStyle(color: Colors.white70)),
    );
  }
}
