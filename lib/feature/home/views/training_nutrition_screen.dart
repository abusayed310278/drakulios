import 'package:flutter/material.dart';

import '../../../core/constants/assets.dart';
import 'widgets/training_header.dart';

class TrainingNutritionScreen extends StatefulWidget {
  const TrainingNutritionScreen({super.key});

  @override
  State<TrainingNutritionScreen> createState() => _TrainingNutritionScreenState();
}

class _TrainingNutritionScreenState extends State<TrainingNutritionScreen> {
  int _tabIndex = 0;

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
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TrainingHeader(
                    //   activeIndex: _tabIndex,
                    //   onTabChange: (index) => setState(() => _tabIndex = index),
                    //   dateTitle: _tabIndex == 0 ? 'Today\'s Challenge!' : 'Today\'s Meal!',
                    //   dateValue: '3rd Feb 2026',
                    // ),
                    if (_tabIndex == 0) ...[
                      TrainingHeader(
                        activeIndex: _tabIndex,
                        onTabChange: (index) => setState(() => _tabIndex = index),
                        dateTitle: _tabIndex == 0 ? 'Today\'s Challenge!' : 'Today\'s Meal!',
                        dateValue: '3rd Feb 2026',
                      ),
                      const SizedBox(height: 12),
                      _TrainingCard(),
                    ] else ...[
                      TrainingHeader(
                        activeIndex: _tabIndex,
                        onTabChange: (index) => setState(() => _tabIndex = index),
                        dateTitle: _tabIndex == 0 ? 'Today\'s Challenge!' : 'Today\'s Meal!',
                        dateValue: '3rd Feb 2026',
                      ),
                      const SizedBox(height: 12),
                      const _MealCard(title: 'Breakfast', time: '7am - 8am', asset: Images.breakfastImage),
                      const SizedBox(height: 10),
                      const _MealCard(title: 'Lunch', time: '12pm - 1pm', asset: Images.lunchImage),
                      const SizedBox(height: 10),
                      const _MealCard(title: 'Dinner', time: '6pm - 8pm', asset: Images.dinnerImage),
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
}

class _TrainingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E2024), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(Images.gym1Image, height: 170, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          const _WorkoutRow(title: 'Dumble Squat', chips: ['3 Set', '2 kg', '10 Reps']),
          const SizedBox(height: 8),
          const _WorkoutRow(title: 'Bench Press', chips: ['4 Set', '2 min', '5 Reps']),
          const SizedBox(height: 8),
          const _WorkoutRow(title: 'Lat Pulldowns', chips: ['4 Set', '90 sec', '8 Reps']),
          const SizedBox(height: 8),
          const _WorkoutRow(title: 'Overhead Press', chips: ['3 Set', '90 sec', '6 Reps']),
          const SizedBox(height: 8),
          const _WorkoutRow(title: 'Bicep Curls', chips: ['3 Set', '45 sec', '15 Reps']),
        ],
      ),
    );
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
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF7B5C16), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      chip,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
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
  const _MealCard({required this.title, required this.time, required this.asset});

  final String title;
  final String time;
  final String asset;

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
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(color: Colors.white, fontSize: 10)),
                const SizedBox(height: 4),
                const Text(
                  'Chicken Breast (100 gm)',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text('P: 31g  C: 0g  F: 3.6g  165cal', style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
